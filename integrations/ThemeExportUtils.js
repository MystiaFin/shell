.pragma library

function colorToHex(colorValue) {
    const channel = value => Math.round(value * 255).toString(16).padStart(2, "0");
    return "#" + channel(colorValue.r) + channel(colorValue.g)
        + channel(colorValue.b);
}

function colorToRgb(colorValue) {
    return Math.round(colorValue.r * 255) + ", "
        + Math.round(colorValue.g * 255) + ", "
        + Math.round(colorValue.b * 255);
}

function applyReplacements(template, replacements) {
    let output = template;
    for (const token in replacements)
        output = output.split(token).join(replacements[token]);
    return output;
}
