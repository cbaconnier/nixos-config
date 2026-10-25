{ pkgs }:

let
  # Pinned CLDR release (Unicode's official emoji keyword annotations) -- richer
  # than rofimoji's bundled short descriptions (e.g. it lists "love" for the red
  # heart). Bump cldrTag (and the two hashes) to pick up newer keywords.
  cldrTag = "48.2.1";
  enAnnotations = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/unicode-org/cldr-json/${cldrTag}/cldr-json/cldr-annotations-full/annotations/en/annotations.json";
    sha256 = "sha256-8iCDy4bf+2OmQ9W6y12YmfgtL6XTiK1POu1yGErO9QU=";
  };
  enAnnotationsDerived = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/unicode-org/cldr-json/${cldrTag}/cldr-json/cldr-annotations-derived-full/annotationsDerived/en/annotations.json";
    sha256 = "sha256-FclFevpwOjLcx41UYmQYqR6CD+Dd1nt9SRxMTZ9YRqs=";
  };
in
pkgs.runCommand "rofimoji-en-keywords" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  rofimojiData=$(echo ${pkgs.rofimoji}/lib/*/site-packages/picker/data)
  python3 ${./generate-keywords.py} "$rofimojiData" ${enAnnotations} ${enAnnotationsDerived} "$out"
''
