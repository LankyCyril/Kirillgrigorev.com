from glob import glob
from csscompressor import compress

def read_css(filenames):
    for filename in filenames:
        with open(filename) as handle:
            for line in handle:
                yield line

def minify_css(filenames):
    css_lines = read_css(filenames)
    return compress("".join(css_lines))

rule all:
    input:
        html="src/html/index.html",
        css=glob("src/css/*.css")
    output: html="index.html"
    params:
        marker="<style id='inline_all' type='text/css'></style>",
        start_tag=" "*8 + "<style type='text/css'>",
        end_tag="</style>\n"
    run:
        with open(input.html) as html_in, open(output.html, "w") as html_out:
            for line in html_in:
                if line.strip() == params.marker:
                    min_css = minify_css(input.css)
                    html_out.write(params.start_tag + min_css + params.end_tag)
                else:
                    html_out.write(line)
