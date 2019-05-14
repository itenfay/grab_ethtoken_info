//
// Created by dyf on 2018/9/6.
// Copyright (c) 2018 dyf.
//

/// [HtmlConverter] convert a paragraph of HTML text into simple standard html.
class HtmlConverter {
  String _source;
  String _title;

  HtmlConverter(String source, {String title}) {
    _source = source;
    _title = title;
  }

  HtmlConverter.init(String source, {String title})
   : this(source, title: title);

  set title(String title) {
    _title = title;
  }
  
  set source(String source) {
    _source = source;
  }

  String convert({bool isTable: false}) {
    if (_source == null) return null;
    if (_source.isEmpty) return _source;
    
    var title = _title ?? "Simple Standard Html";
    var body = isTable ? """
      <table>
        <tbody id="tb1">$_source</tbody>
      </table>
    """ : "$_source";

    return """
      <!doctype html>
      <html>
      <head>
        <title>$title</title>
        <meta charset="utf-8">
      </head>
      <body>
        $body
      </body>
      </html>""";
  }
}
