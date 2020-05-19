# setup

src_dir = "src"
build_dir = "build"
assets_dir = "assets"

if !isdir(build_dir)
	println("Creating build  directory at \"", build_dir, "\"")
	mkdir(build_dir)
end

cp(src_dir*"/"*assets_dir, build_dir*"/"*assets_dir, force=true)

# Run Code Example and include it
cd(src_dir)
run(`julia example.jl`)
mv("example.svg", "../"*build_dir*"/"*assets_dir*"/example.svg")

placeholder = "[example.jl]"
ex = read("example.jl", String)
html = read("index.html", String)
html_built = replace(html, placeholder => ex)
write("../"*build_dir*"/index.html", html_built)