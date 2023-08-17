# jigmo

Website: https://kamichikoichi.github.io/jigmo/

Jigmoフォントを生成するツール一式です。

WSL(Windows Subsystem for Linux) を含むLinux環境で動かすことを想定しています。以下のパッケージを用意してください。

```
% sudo apt install fontforge-nox fonttools
```

一式をコピーします。

```
% git clone https://github.com/kamichikoichi/jigmo
```

実行します。

```
% ./tasks
```

buildフォルダ内に一式が生成されます。グリフウィキからのSVGファイルの取得およびttfファイルの生成に併せて数時間かかります。SVGファイルはwork/glyphフォルダ内に保存されますが、すでにファイルが存在する場合は取得しません。ネットワークエラーなどで取得に失敗した場合は、途中で止まりますので、単純にtasksを再実行してください。

非漢字はUnicodeで配布されているUnicodeData.txtの中からkeywords.txtの各行を含むものを取り込みます。ただしSPACE, FILLERを含むものは含めません。
