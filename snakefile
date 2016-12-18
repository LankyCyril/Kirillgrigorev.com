from glob import glob
from csscompressor import compress
from htmlmin import minify
from base64 import b64encode
from urllib.parse import quote_from_bytes
from shutil import which
from subprocess import call

rule all:
    input: "index.html", "cv/index.html"

rule min_html:
    input: html="temp/{name}.htm"
    output: html="{name}.html"
    run:
        with open(input.html) as html_in:
            uncompressed = html_in.read()
        raw_compressed = minify(
            uncompressed,
            remove_comments=True,
            reduce_boolean_attributes=True,
            remove_all_empty_space=True
        )
        compressed = raw_compressed.replace("&bsp;", " ")
        with open(output.html, "w") as html_out:
            html_out.write(compressed)

rule intermediate_index:
    input:
        html="src/html/index.html",
        css="temp/min.css"
    output: html=temp("temp/index.htm")
    params:
        marker="<style id='inline_all' type='text/css'></style>",
        start_tag="<style type='text/css'>",
        end_tag="</style>"
    run:
        with open(input.html) as html_in, open(output.html, "w") as html_out:
            for line in html_in:
                if line.strip() == params.marker:
                    with open(input.css) as css_in:
                        min_css = css_in.read()
                    html_out.write(params.start_tag + min_css + params.end_tag)
                else:
                    html_out.write(line)

rule min_css:
    input: css=glob("src/css/*.css")
    output: css=temp("temp/min.css")
    run:
        with open(output.css, "w") as css_out:
            for css_file in input.css:
                with open(css_file) as css_in:
                    min_css = compress(css_in.read())
                    css_out.write(min_css)

rule intermediate_cv_index:
    input:
        html="src/html/cv/index.html",
        png="temp/preview-blurred.png"
    output: html=temp("temp/cv/index.htm")
    params:
        marker="<img id='inline_all'>",
        replacement="<img src='data:image/png;base64,{}'/>"
    run:
        with open(input.html) as html_in, open(output.html, "w") as html_out:
            for line in html_in:
                if line.strip() == params.marker:
                    with open(input.png, "rb") as png_handle:
                        raw_b64data = b64encode(png_handle.read())
                        b64data = quote_from_bytes(raw_b64data)
                    html_out.write(params.replacement.format(b64data))
                else:
                    html_out.write(line)

rule compress_png:
    input: png="src/img/preview-blurred.png"
    output: png=temp("temp/preview-blurred.png")
    run:
        if which("optipng"):
            call(["optipng", "-o7", "-zm1-9", "-out", output.png, input.png])
        else:
            call(["cp", input.png, output.png])
