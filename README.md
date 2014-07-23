---
title: A Markdown workflow for writing documents
author:
- name: Pietro Bertera
  affiliation: bertera.it
  email: pietro@bertera.it

date: Jul 2014
abstract: A simple writing workflow using markdown, GNU/Make, convert and pandoc.
...

# A Markdown workflow for writing documents

## Why Markdown ?

* [Markdown](http://en.wikipedia.org/wiki/Markdown) is a simple formatting syntax, the syntax is very simple and powerful, markdown has a flat learning curve

* Markdown saves time (and money): writing in markdown is fast: you don't must fight with a complicated syntax (read: LaTeX) nor you will never lose in a deep and deep XML tree (read: Docbook) and you will never need a buggy WYSIWYG editor.

* Markdown is plaintext, so you can use your preferred text editor and showing differences between documents is easy and you can use some tool (diff).

* Markdown is portable: you can write your docs in your smartphone, in your web editor or in your standalone application.

* Markdown is human readable: also without any rendering process a markdown is clean and easy to understand

* Markdown is flexible: you can easily convert a Markdown document into an HTML, a PDF a DOCX or whatever in a few simple step

* Markdown supports workflows: with some tools and a simple setup you can automatize your writing-release-publish-print-whatever process: you can script the rendering process, or the publishing and so on.

## Images resize issue

A drawback of markdown is that doesn't officially supports an image resize syntax.

This limitation can be justified by the fact that often the wanted image size depends on the final document format. If your document is rendered as HTML maybe you want bigger images than in A4 PDF rendering.

This limitation can be circumvented using little script and a rule file: the rule file resides along with the file and has a the same name of the image file followed by the suffix `.sizes` E.g.: the image **tls-enforcing.png** has a rule file named **tls-enforcing.png.sizes**.

The rule file contains a list of [convert](http://www.imagemagick.org/script/convert.php) options grouped by format:


**tls-enforcing.png.sizes**

```
# This is a comment and will be ignored during the parsing
# The following rule instructs the convert tool to resize 
# the image to the specified size
pdf:-resize 400x50
# The following rule specify a width of 300px for the HTML format
html:-resize 300
# All others format should be unchanged
ALL:
```

### The *convert-img.sh* script:

This bash script should be launched with 4 command line arguments:

* the image file path
* the needed format
* a directory where the image should copied (after processed by *convert*)

When the script runs it search for the rule file, the rule file is parsed against the format and then the convert command is launched with the format specific options.

So, running the script:

`./scripts/onvert-img.sh img/tls-enforcing.png pdf gen/pdf/img`

The following command will be launched:

`convert -resize 400x50 img/tls-enforcing.png gen/pdf/img/tls-enforcing.png`

In case the rule file is missing or he rule file doesn't contains the needed format the image will be copied as is into the destination directory.

## The working tree

Following my working directory:

```
.
|____img/                           <--- *img*: the image directory          
| |____tls-unknown.png                   containing all images
| |____tls-unknown.png.sizes             along with rule files
| |____8021p.png
| |____8021p.png.sizes
| |____tls-enforcing.png
| |____tls-enforcing.png.sizes
| |____vlan-wireshark.png
| |____vlan-wireshark.png.sizes
|
|____Makefile                       <--- the Makefile
|
|____Networking.md                  <--- Markdown documents
|____Security.md
|____README.md
|
|____scripts/                       <--- Scripts directory containing
| |____convert-img.sh                    the convert-img.sh script 
|
|____tpl/                           <--- a template directory containing
| |____Byword.css                        stylesheets, html templates
| |____kultiad-serif.css                 LaTeX templates etc...
| |____latex.template
| |____latex.tex
| |____paper.css
| |____style.css
| |____template.html
| |____template.tex
```

## Editing

You can use your [preferred](http://www.vim.org/) text [editor](http://www.gnu.org/software/emacs/), I like to use [Mou](http://mouapp.com/):

![The mou editor](img/mou.png)

## Generating the output document

The output document can be easily generated trough the *GNU/Make* command:

`make html` 

Will generate an HTML document into the gen/html/ directory for each Markdown document into the main directory:

```
gen/html/
|____img
|    |____tls-unknown.png
|    |____8021p.png
|    |____tls-enforcing.png
|    |____vlan-wireshark.png
|
|____tpl
|    |____style.css
|    |____template.html
|
|____Networking.html
|____README.html
|____security.html
```

Same thing for *make pdf* and *make docx* commands. *make all* command will export HTML, PDF and DOCX formats.

You can easily configure the whole workflow editing the *Makefile* and format templates.
