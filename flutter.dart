import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

void main() async {
try{
  final url = "https://iptv-org.github.io/iptv/index.category.m3u";
  // final url = "https://iptv-org.github.io/iptv/index.m3u";
  final jsonResult = await fetchAndConvertM3U(url);
  for(var line  in jsonResult){
    if(line['title']?.toLowerCase().contains('mbc 4')==true)
    print("jsonResult ${jsonEncode(line)}");

  }

}catch(e){
  print(e.toString());
}
}

Future<List<Map<String, String>>> fetchAndConvertM3U(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return parseM3U(response.body);
  } else {
    throw Exception("Failed to load M3U file");
  }
}

List<Map<String, String>> parseM3U(String m3uContent) {

  final List<Map<String, String>> channels = [];
  final lines = m3uContent.split("\n");

  String? currentTitle;
  String? currentGroup;
  String? currentLogo;

  for (var line in lines) {

    line = line.trim();

    if (line.startsWith("#EXTINF:")) {
      final matches = RegExp(r'tvg-logo="(.*?)"').firstMatch(line);
      currentLogo = matches?.group(1) ?? '';

      final titleMatch = RegExp(r',(.+)$').firstMatch(line);
      currentTitle = titleMatch?.group(1)?.trim() ?? '';

      final groupMatch = RegExp(r'group-title="(.*?)"').firstMatch(line);
      currentGroup = groupMatch?.group(1) ?? '';
    } else if (line.isNotEmpty && !line.startsWith("#")) {
      channels.add({
        "title": currentTitle ?? "Unknown",
        "group": currentGroup ?? "General",
        "logo": currentLogo ?? "",
        "url": line,
      });
    }
  }
  return channels;
}
