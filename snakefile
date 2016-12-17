from glob import glob
from csscompressor import compress
from htmlmin import minify

rule all:
    input: html="temp/index.html"
    output: html="index.html"
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

rule intermediate_html:
    input:
        html="src/html/index.html",
        css="temp/min.css"
    output: html=temp("temp/index.html")
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
