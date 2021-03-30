import 'dart:io';

List<String> readFileByLines() {
  File file = new File('0BSD.xml');
  // sync
  List<String> lines = file.readAsLinesSync();
  return lines;
}

void xmlParser(String fileName) {
  File file = new File(fileName);
  List<String> tags = []; //as stack to hold the tags
  List<String> lines = file.readAsLinesSync();
  Map<String, String> formatedLicense = {};
  //check the first two lines for xml and spdx validation
  if (!(lines[0].contains("<?xml version=") &&
      lines[0].contains("encoding=\"UTF-8\"?>"))) {
    print('Not a valid xml file');
    return;
  }
  if (lines[1] !=
          ('<SPDXLicenseCollection xmlns=\"http://www.spdx.org/license\">') ||
      lines[lines.length - 1] != '</SPDXLicenseCollection>') {
    print(lines[1] + lines[lines.length - 1]);
    print('Not a valid SPDX license');
    return;
  }
  if (lines[2].contains('<license isOsiApproved="true"') &&
      lines[lines.length - 2].contains('</license>')) {
    List<String> splittedTextForLicenseHeader = lines[2].split('\"');
    print(splittedTextForLicenseHeader);
    int licenseIdIndex =
        lines.indexWhere((element) => element.contains('licenseId='));
    print(licenseIdIndex);
    formatedLicense.addAll({
      "Full name": splittedTextForLicenseHeader[licenseIdIndex + 3],
      "Short identifier": splittedTextForLicenseHeader[licenseIdIndex + 1],
    });
    print(formatedLicense);
  } else {
    print(lines[2] + lines[lines.length - 2]);
    print('Not a valid SPDX license');
    return;
  }
  for (int i = 3; i < lines.length - 2; i++) {}
}

void main() async {
  xmlParser('0BSD.xml');
}
