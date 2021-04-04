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
  int tagsitterator = -1;
  List<String> lines = file.readAsLinesSync();
  Map<Map<String, String>, int> formatedLicense = {}; //{tag:value}:level
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
    //print(splittedTextForLicenseHeader);
    int licenseIdIndex =
        lines.indexWhere((element) => element.contains('licenseId='));
    //print(licenseIdIndex);
    formatedLicense.addAll({
      {
        "Full name": splittedTextForLicenseHeader[licenseIdIndex + 3],
      }: 0,
      {
        "Short identifier": splittedTextForLicenseHeader[licenseIdIndex + 1],
      }: 0,
    });
  } else {
    print(lines[2] + lines[lines.length - 2]);
    print('Not a valid SPDX license');
    return;
  }
  String temp = '';
  for (int i = 3; i < lines.length - 2; i++) {
    if (lines[i].isEmpty) {
      continue;
    }
    int stringIttertor = 0;
    while (lines[i][stringIttertor] == ' ') {
      stringIttertor++;
    }
    if (lines[i].indexOf('<') == -1) // not a tag
    {
      temp += ' ' + lines[i].substring(stringIttertor);
    } else if (lines[i].indexOf('<') == lines[i].lastIndexOf('<')) {
      // only one tag at line
      if (lines[i][lines[i].indexOf('<') + 1] == '/') {
        //closing tag
        if (stringIttertor != lines[i][lines[i].indexOf('<')]) {
          //had text before the closing tag
          temp +=
              ' ' + lines[i].substring(stringIttertor, lines[i].indexOf('<'));
        }
        stringIttertor = lines[i].indexOf('<') + 1;
        if (lines[i].substring(stringIttertor + 1, lines[i].length - 1) ==
            tags[tagsitterator]) {
          formatedLicense.addAll(
            {
              {tags[tagsitterator]: temp}: tagsitterator + 1
            },
          );
          tags.remove(tags[tagsitterator]);
          tagsitterator--;
        }
        /* else {
          print(
              '${tags[tagsitterator]} => ${lines[i].substring(stringIttertor + 1, lines[i].length - 1)}');
        } */
        temp = '';
      } else if (lines[i][lines[i].indexOf('<') + 1] != '/') {
        //opening tag
        tags.add(lines[i]
            .substring(lines[i].indexOf('<') + 1, lines[i].indexOf('>')));
        tagsitterator++;
        temp += lines[i].substring(lines[i].indexOf('>') + 1);
      }
    } else {
      while (lines[i].indexOf('<') > stringIttertor) {
        stringIttertor++;
      }
      //more than one tag
      if (lines[i][lines[i].indexOf('<')] == lines[i][stringIttertor] &&
          lines[i][lines[i].indexOf('<') + 1] != '/') {
        //opening tag
        int startingTagIndex = stringIttertor;
        stringIttertor++;
        while (lines[i][stringIttertor] != '>') {
          stringIttertor++;
        }
        tags.add(lines[i].substring(startingTagIndex + 1, stringIttertor++));
        tagsitterator += 1;
        while (lines[i][stringIttertor] != '<') {
          temp += lines[i][stringIttertor];
          stringIttertor++;
        }
      }
      if (lines[i][stringIttertor + 1] == '/') {
        //closing tag
        if (lines[i].substring(stringIttertor + 2, lines[i].length - 1) ==
            tags[tagsitterator]) {
          formatedLicense.addAll(
            {
              {tags[tagsitterator]: temp}: tagsitterator + 1
            },
          );
          temp = '';
          tags.remove(tags[tagsitterator]);
          tagsitterator -= 1;
        } else {
          print(
              '${tags[tagsitterator]} => ${lines[i].substring(stringIttertor + 2, lines[i].length - 1)}');
        }
      }
    }
    //print('${lines[i].indexOf('<')}   =>   ${lines[i].lastIndexOf('<')}');
  }
  print(formatedLicense);
}

void main() async {
  xmlParser('0BSD.xml');
}
