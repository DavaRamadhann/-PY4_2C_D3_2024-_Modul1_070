import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum PcdFilterType {
  original,
  grayscale,
  brightness,
  histogramEqualization,
  averageBlur,
  sharpen,
  edgeDetection,
}

class PCDService {
  // Method to process image based on selected filter.
  // We make it static so it can be called easily within an Isolate (Compute).
  static Uint8List processImage(Map<String, dynamic> params) {
    Uint8List imageBytes = params['imageBytes'];
    PcdFilterType filter = params['filterType'];

    // Decode original image
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imageBytes;

    // Optional: Resize image slightly if too big to avoid memory issues on mobile
    // Width 1080 is a good baseline for processing
    if (originalImage.width > 1080) {
      originalImage = img.copyResize(originalImage, width: 1080);
    }

    img.Image processedImage;

    switch (filter) {
      case PcdFilterType.original:
        processedImage = originalImage;
        break;
      case PcdFilterType.grayscale:
        processedImage = applyGrayscale(originalImage);
        break;
      case PcdFilterType.brightness:
        processedImage = applyBrightness(originalImage, 50); // Add 50 intensity
        break;
      case PcdFilterType.histogramEqualization:
        processedImage = applyHistogramEqualization(originalImage);
        break;
      case PcdFilterType.averageBlur:
        // Kernel 3x3 Average Blur: [1,1,1] / 9
        List<num> blurKernel = List.filled(9, 1 / 9);
        processedImage = applyConvolution(originalImage, blurKernel);
        break;
      case PcdFilterType.sharpen:
        // Kernel 3x3 Sharpen
        List<num> sharpenKernel = [
          0, -1, 0,
          -1, 5, -1,
          0, -1, 0
        ];
        processedImage = applyConvolution(originalImage, sharpenKernel);
        break;
      case PcdFilterType.edgeDetection:
        // Kernel 3x3 Edge Detection (Laplacian/Sobel proxy)
        List<num> edgeKernel = [
          -1, -1, -1,
          -1, 8, -1,
          -1, -1, -1
        ];
        processedImage = applyConvolution(originalImage, edgeKernel);
        break;
    }

    // Encode back to bytes (JPG for smaller memory usage in flutter UI)
    return Uint8List.fromList(img.encodeJpg(processedImage, quality: 90));
  }

  // 1. Grayscale Filter
  static img.Image applyGrayscale(img.Image inputImage) {
    return img.grayscale(inputImage.clone());
  }

  // 2. Brightness (Aritmatika Add/Subtract)
  static img.Image applyBrightness(img.Image inputImage, int amount) {
    final image = inputImage.clone();
    for (var p in image) {
      p.r = (p.r + amount).clamp(0, 255);
      p.g = (p.g + amount).clamp(0, 255);
      p.b = (p.b + amount).clamp(0, 255);
    }
    return image;
  }

  // 3. Histogram Equalization
  static img.Image applyHistogramEqualization(img.Image inputImage) {
    final image = inputImage.clone();
    
    // We base the equalize map on luminance/grayscale to avoid weird color shifts
    final grayImage = img.grayscale(inputImage.clone());
    
    // a. Calculate Histogram
    List<int> histogram = List<int>.filled(256, 0);
    for (var p in grayImage) {
      histogram[p.r as int]++; 
    }
    
    // b. Calculate CDF (Cumulative)
    List<int> cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
        cdf[i] = cdf[i-1] + histogram[i];
    }
    
    // c. Find Min CDF
    int cdfMin = 0;
    for (int i = 0; i < 256; i++) {
        if (cdf[i] > 0) {
            cdfMin = cdf[i];
            break;
        }
    }
    
    int totalPixels = image.width * image.height;
    
    // d. Equalization Mapping function
    List<int> hMap = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
        hMap[i] = ((cdf[i] - cdfMin) / (totalPixels - cdfMin) * 255).round().clamp(0, 255);
    }
    
    // e. Apply Histogram Map
    for (var p in image) {
      p.r = hMap[p.r as int];
      p.g = hMap[p.g as int];
      p.b = hMap[p.b as int];
    }
    
    return image;
  }

  // 4. Convolution Filter
  static img.Image applyConvolution(img.Image inputImage, List<num> kernel) {
    // using the convolution function provided by flutter 'image' package 
    // which iterates the matrix
    return img.convolution(inputImage.clone(), filter: kernel);
  }
}
