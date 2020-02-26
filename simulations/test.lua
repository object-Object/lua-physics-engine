require("print_r")
a={["a"]="b",["n"]="s",["c"]="a"}
table.sort(a,function(a,b) return a<b end)
print_r(a)