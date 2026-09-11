.pragma library

function build(rgbData, width, height) {
    const bytes = new Uint8Array(rgbData);
    const pixelCount = width * height;
    if (bytes.length !== pixelCount * 3)
        return null;

    const luminance = new Array(pixelCount);
    const squared = new Array(pixelCount);
    const detail = new Array(pixelCount);

    for (let y = 0; y < height; ++y) {
        for (let x = 0; x < width; ++x) {
            const index = y * width + x;
            const byteIndex = index * 3;
            const value = (bytes[byteIndex] * 0.2126
                + bytes[byteIndex + 1] * 0.7152
                + bytes[byteIndex + 2] * 0.0722) / 255;

            luminance[index] = value;
            squared[index] = value * value;
            detail[index] = (x > 0 ? Math.abs(value - luminance[index - 1]) : 0)
                + (y > 0 ? Math.abs(value - luminance[index - width]) : 0);
        }
    }

    return {
        stride: width + 1,
        luminance: integralImage(luminance, width, height),
        squared: integralImage(squared, width, height),
        detail: integralImage(detail, width, height)
    };
}

function colorLuminance(colorValue) {
    return colorValue.r * 0.2126
        + colorValue.g * 0.7152
        + colorValue.b * 0.0722;
}

function score(rectangle, analysis, textLuminance, textOnly) {
    const stats = regionStats(rectangle, analysis);

    // Cards with a background mainly want a calm, low-detail area.
    if (!textOnly)
        return -stats.deviation * 12 - stats.detail * 10;

    // The clock has no card background, so contrast matters as well.
    const contrast = (Math.max(textLuminance, stats.mean) + 0.05)
        / (Math.min(textLuminance, stats.mean) + 0.05);
    return Math.min(4, contrast) * 0.25
        - stats.deviation * 6
        - stats.detail * 6;
}

function integralImage(values, width, height) {
    const stride = width + 1;
    const result = new Array(stride * (height + 1)).fill(0);

    for (let y = 1; y <= height; ++y) {
        let rowSum = 0;
        for (let x = 1; x <= width; ++x) {
            rowSum += values[(y - 1) * width + x - 1];
            result[y * stride + x] = result[(y - 1) * stride + x] + rowSum;
        }
    }

    return result;
}

function regionStats(rectangle, analysis) {
    const area = Math.max(1, rectangle.width * rectangle.height);
    const mean = rectangleSum(analysis.luminance, analysis.stride, rectangle) / area;
    const squaredMean = rectangleSum(analysis.squared, analysis.stride, rectangle) / area;

    return {
        mean: mean,
        deviation: Math.sqrt(Math.max(0, squaredMean - mean * mean)),
        detail: rectangleSum(analysis.detail, analysis.stride, rectangle) / area
    };
}

function rectangleSum(integral, stride, rectangle) {
    const right = rectangle.x + rectangle.width;
    const bottom = rectangle.y + rectangle.height;

    return integral[bottom * stride + right]
        - integral[rectangle.y * stride + right]
        - integral[bottom * stride + rectangle.x]
        + integral[rectangle.y * stride + rectangle.x];
}
