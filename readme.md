install mousetrap
you cant use pkg, you have to go into the julia repl and run this script (copy paste it)
"
import Pkg;
begin
    Pkg.add(url="https://github.com/clemapfel/mousetrap.jl")
    Pkg.test("Mousetrap")
end"
"
