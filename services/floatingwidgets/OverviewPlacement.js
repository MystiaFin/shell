.pragma library

.import "WallpaperAnalysis.js" as WallpaperAnalysis

// The algorithm only considers these predictable edge positions.
// That keeps placement deterministic and cheap enough to understand at a glance.
const ANCHORS = [
    "topLeft", "topCenter", "topRight",
    "middleLeft", "middleRight",
    "bottomLeft", "bottomCenter", "bottomRight"
];

// Public entry point ---------------------------------------------------------

function calculate(request, analysis, cardGap) {
    const bounds = sampleBounds(request);
    const gap = Math.max(1, Math.round(cardGap
        / request.screenWidth * request.sampleWidth));
    const cards = createCards(request);

    const primaryCandidates = buildPrimaryCandidates(cards, bounds, request,
        analysis, gap);

    let bestSolution = null;
    let bestScore = -Infinity;

    for (let i = 0; i < primaryCandidates.length; ++i) {
        const primary = primaryCandidates[i];
        const occupied = primary.occupied.slice();

        const resources = bestGroupPlacement([
            verticalLayout(cards.resources, gap),
            horizontalLayout(cards.resources, gap)
        ], bounds, request, analysis, occupied, gap);
        if (!resources)
            continue;
        occupied.push(resources);

        const environment = bestGroupPlacement([
            verticalLayout(cards.environment, gap),
            horizontalLayout(cards.environment, gap)
        ], bounds, request, analysis, occupied, gap);
        if (!environment)
            continue;

        const balancePenalty = horizontalBalancePenalty([
            primary.group, resources, environment
        ], request.sampleWidth);
        const score = primary.score + resources.score
            + environment.score - balancePenalty;

        if (score > bestScore) {
            bestScore = score;
            bestSolution = {
                primary: primary,
                resources: resources,
                environment: environment
            };
        }
    }

    if (!bestSolution)
        return null;

    const positions = {};
    copyCardPositions(positions, bestSolution.primary.group, request);
    if (bestSolution.primary.clock)
        copyCardPositions(positions, bestSolution.primary.clock, request);
    copyCardPositions(positions, bestSolution.resources, request);
    copyCardPositions(positions, bestSolution.environment, request);

    return { positions: positions };
}

// Placement strategy --------------------------------------------------------

function buildPrimaryCandidates(cards, bounds, request, analysis, gap) {
    const candidates = [];

    // First try clock + weather + calendar as one group.
    const joinedLayouts = [
        horizontalLayout([cards.clock, cards.weather, cards.calendar], gap),
        verticalLayout([cards.clock, cards.weather, cards.calendar], gap)
    ];
    for (let i = 0; i < joinedLayouts.length; ++i) {
        const placements = placementsForLayout(joinedLayouts[i], bounds,
            request, analysis, [], gap, false);
        for (let j = 0; j < placements.length; ++j) {
            candidates.push({
                score: placements[j].score + 0.2,
                group: placements[j],
                clock: null,
                occupied: [placements[j]]
            });
        }
    }

    // Also allow the clock to float independently from weather + calendar.
    const infoLayouts = [
        horizontalLayout([cards.weather, cards.calendar], gap),
        verticalLayout([cards.weather, cards.calendar], gap)
    ];
    const clockLayout = horizontalLayout([cards.clock], 0);
    const clockPlacements = placementsForLayout(clockLayout, bounds,
        request, analysis, [], gap, true);

    for (let i = 0; i < infoLayouts.length; ++i) {
        const groups = placementsForLayout(infoLayouts[i], bounds,
            request, analysis, [], gap, false);

        for (let groupIndex = 0; groupIndex < groups.length; ++groupIndex) {
            for (let clockIndex = 0; clockIndex < clockPlacements.length;
                    ++clockIndex) {
                const group = groups[groupIndex];
                const clock = clockPlacements[clockIndex];
                if (overlaps(group, clock, gap * 2))
                    continue;

                candidates.push({
                    score: (group.score * 2 + clock.score) / 3,
                    group: group,
                    clock: clock,
                    occupied: [group, clock]
                });
            }
        }
    }

    candidates.sort((a, b) => b.score - a.score);
    return candidates.slice(0, 16);
}

function bestGroupPlacement(layouts, bounds, request, analysis, occupied, gap) {
    let best = null;

    for (let i = 0; i < layouts.length; ++i) {
        const placements = placementsForLayout(layouts[i], bounds, request,
            analysis, occupied, gap, false);
        if (placements.length > 0 && (!best || placements[0].score > best.score))
            best = placements[0];
    }

    return best;
}

function placementsForLayout(layout, bounds, request, analysis, occupied,
        gap, textOnly) {
    const placements = [];

    for (let i = 0; i < ANCHORS.length; ++i) {
        const point = positionAtAnchor(ANCHORS[i], layout, bounds);
        if (!point)
            continue;

        const placement = makePlacement(layout, point.x, point.y,
            request.sampleWidth);
        if (collides(placement, occupied, gap * 2))
            continue;

        placement.score = scorePlacement(placement, request, analysis,
            textOnly) - centerPenalty(placement, request);
        placements.push(placement);
    }

    placements.sort((a, b) => b.score - a.score
        || a.y - b.y || a.x - b.x);
    return placements;
}

// Scoring -------------------------------------------------------------------

function scorePlacement(placement, request, analysis, textOnly) {
    let total = 0;
    for (let i = 0; i < placement.cards.length; ++i) {
        total += WallpaperAnalysis.score(placement.cards[i], analysis,
            request.textLuminance, textOnly);
    }
    return total / placement.cards.length;
}

function centerPenalty(placement, request) {
    const protectedRegion = {
        x: Math.round(request.sampleWidth * 0.25),
        y: Math.round(request.sampleHeight * 0.16),
        width: Math.round(request.sampleWidth * 0.5),
        height: Math.round(request.sampleHeight * 0.68)
    };
    const area = Math.max(1, placement.width * placement.height);
    return intersectionArea(placement, protectedRegion) / area * 5;
}

function horizontalBalancePenalty(groups, sampleWidth) {
    let left = 0;
    for (let i = 0; i < groups.length; ++i) {
        const center = groups[i].x + groups[i].width / 2;
        if (center < sampleWidth / 2)
            ++left;
    }
    return Math.abs(left - (groups.length - left)) * 0.35;
}

// Card model ----------------------------------------------------------------

function createCards(request) {
    const resourceSize = sampleSize(request.resourceSize, request);
    const environmentSize = sampleSize(request.environmentSize, request);

    const resources = [
        namedCard("cpuTemperature", resourceSize),
        namedCard("cpuUsage", resourceSize)
    ];
    if (request.gpuAvailable)
        resources.push(namedCard("gpuTemperature", resourceSize));

    const environment = [
        namedCard("uvIndex", environmentSize),
        namedCard("humidity", environmentSize)
    ];
    if (request.airQualityAvailable)
        environment.push(namedCard("airQuality", environmentSize));

    return {
        clock: namedCard("clock", sampleSize(request.clockSize, request)),
        weather: namedCard("weather", sampleSize(request.weatherSize, request)),
        calendar: namedCard("calendar", sampleSize(request.calendarSize, request)),
        resources: resources,
        environment: environment
    };
}

function namedCard(name, size) {
    return { name: name, width: size.width, height: size.height };
}

function sampleSize(sizeValue, request) {
    return {
        width: Math.max(2, Math.round(sizeValue.width
            / request.screenWidth * request.sampleWidth)),
        height: Math.max(2, Math.round(sizeValue.height
            / request.screenHeight * request.sampleHeight))
    };
}

function sampleBounds(request) {
    const left = clamp(Math.round(request.usableArea.x
        / request.screenWidth * request.sampleWidth), 0, request.sampleWidth);
    const top = clamp(Math.round(request.usableArea.y
        / request.screenHeight * request.sampleHeight), 0, request.sampleHeight);
    const right = clamp(Math.round((request.usableArea.x + request.usableArea.width)
        / request.screenWidth * request.sampleWidth), left, request.sampleWidth);
    const bottom = clamp(Math.round((request.usableArea.y + request.usableArea.height)
        / request.screenHeight * request.sampleHeight), top, request.sampleHeight);

    return { x: left, y: top, width: right - left, height: bottom - top };
}

// Geometry helpers ----------------------------------------------------------

function horizontalLayout(cards, gap) {
    let width = 0;
    let height = 0;
    for (let i = 0; i < cards.length; ++i) {
        width += cards[i].width;
        height = Math.max(height, cards[i].height);
    }
    width += gap * Math.max(0, cards.length - 1);

    let x = 0;
    const result = [];
    for (let i = 0; i < cards.length; ++i) {
        const card = cards[i];
        result.push({
            name: card.name,
            x: x,
            y: Math.round((height - card.height) / 2),
            width: card.width,
            height: card.height
        });
        x += card.width + gap;
    }

    return { width: width, height: height, cards: result, vertical: false };
}

function verticalLayout(cards, gap) {
    let width = 0;
    let height = 0;
    for (let i = 0; i < cards.length; ++i) {
        width = Math.max(width, cards[i].width);
        height += cards[i].height;
    }
    height += gap * Math.max(0, cards.length - 1);

    let y = 0;
    const result = [];
    for (let i = 0; i < cards.length; ++i) {
        const card = cards[i];
        result.push({
            name: card.name,
            x: 0,
            y: y,
            width: card.width,
            height: card.height
        });
        y += card.height + gap;
    }

    return { width: width, height: height, cards: result, vertical: true };
}

function positionAtAnchor(anchor, layout, bounds) {
    if (layout.width > bounds.width || layout.height > bounds.height)
        return null;

    const left = bounds.x;
    const centerX = Math.round(bounds.x + (bounds.width - layout.width) / 2);
    const right = bounds.x + bounds.width - layout.width;
    const top = bounds.y;
    const centerY = Math.round(bounds.y + (bounds.height - layout.height) / 2);
    const bottom = bounds.y + bounds.height - layout.height;

    switch (anchor) {
    case "topLeft": return { x: left, y: top };
    case "topCenter": return { x: centerX, y: top };
    case "topRight": return { x: right, y: top };
    case "middleLeft": return { x: left, y: centerY };
    case "middleRight": return { x: right, y: centerY };
    case "bottomLeft": return { x: left, y: bottom };
    case "bottomCenter": return { x: centerX, y: bottom };
    case "bottomRight": return { x: right, y: bottom };
    }
    return null;
}

function makePlacement(layout, x, y, sampleWidth) {
    const alignRight = layout.vertical
        && x + layout.width / 2 >= sampleWidth / 2;
    const cards = [];

    for (let i = 0; i < layout.cards.length; ++i) {
        const card = layout.cards[i];
        cards.push({
            name: card.name,
            x: x + (layout.vertical && alignRight
                ? layout.width - card.width : card.x),
            y: y + card.y,
            width: card.width,
            height: card.height
        });
    }

    return {
        x: x,
        y: y,
        width: layout.width,
        height: layout.height,
        cards: cards,
        score: 0
    };
}

function copyCardPositions(target, placement, request) {
    for (let i = 0; i < placement.cards.length; ++i) {
        const card = placement.cards[i];
        target[card.name] = {
            xRatio: card.x / request.sampleWidth,
            yRatio: card.y / request.sampleHeight
        };
    }
}

function collides(candidate, occupied, margin) {
    for (let i = 0; i < occupied.length; ++i) {
        if (overlaps(candidate, occupied[i], margin))
            return true;
    }
    return false;
}

function overlaps(a, b, margin) {
    return a.x < b.x + b.width + margin
        && a.x + a.width + margin > b.x
        && a.y < b.y + b.height + margin
        && a.y + a.height + margin > b.y;
}

function intersectionArea(a, b) {
    const width = Math.max(0,
        Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x));
    const height = Math.max(0,
        Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y));
    return width * height;
}

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value));
}
