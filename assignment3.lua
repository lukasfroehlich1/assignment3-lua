-- ExprC Definitions

NumC = {}                          
function NumC:new(n1)                 
  local newObj = {val = n1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function NumC:getType()              
  return "NumC"
end

IdC = {}                          
function IdC:new(s1)
  local newObj = {val = s1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function IdC:getType()              
  return "IdC"
end

BinopC = {}                          
function BinopC:new(n1, l1, r1)                 
  local newObj = {name = n1, 
                  left = l1, 
                  right = r1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function BinopC:getType()              
  return "BinopC"
end

IfC = {}                          
function IfC:new(c1, t1, f1)                 
  local newObj = {test = c1, 
                  t = t1, 
                  f = f1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function IfC:getType()              
  return "IfC"
end

AppC = {}                          
function AppC:new(f1, a1)                 
  local newObj = {fun = f1,
                  args = a1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function AppC:getType()              
  return "AppC"
end

LamC = {}                          
function LamC:new(p1, b1)                 
  local newObj = {params = p1,
                  body = b1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function LamC:getType()              
  return "LamC"
end

BoolC = {}                          
function BoolC:new(b1)                 
  local newObj = {val = b1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function BoolC:getType()              
  return "BoolC"
end

NumV = {}                          
function NumV:new(n1)                 
  local newObj = {val = n1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function NumV:getType()              
  return "NumV"
end

CloV = {}                          
function CloV:new(p1, b1, e1)                 
  local newObj = {params = p1,
                  body = b1,
                  env = e1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function CloV:getType()              
  return "CloV"
end

BoolV = {}                          
function BoolV:new(b1)                 
  local newObj = {val = b1}
  self.__index = self               
  return setmetatable(newObj, self) 
end
function BoolV:getType()              
  return "BoolV"
end


-- Set to represent binop values
function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end


-- binop contains all of the binop forms
local binop = Set {"+", "-", "*", "/", "<=", "eq?"}


-- len computes the length of a table
function len(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- doesnt work now----------------------
function check_exn(fun, ...)
	local status, err = pcall(fun, unpack(arg))

	print(status)
	print(err)

	return not status
end

function dummy(x)
	if x == 3 then
		error("bad")
	end
end

--assert(check_exn(dummy, 3))
-------------------

-- parse_args consumes a list of args and parses each element
function parse_args(args) 
    result = {}

    for i=1,len(args) do
        table.insert(result, parse({args[i]}))
    end
    
    return result
end

-- consumes an sexp and returns a ExprC
function parse(sexp) 
	if type(sexp[1]) == "number" then
		return NumC:new(sexp[1])
	elseif type(sexp[1]) == "boolean" then
		return BoolC:new(sexp[1])
	elseif type(sexp[1]) == "string" then
		return IdC:new(sexp[1])
    elseif type(sexp[1]) == "table" then
        if sexp[1][1] == "if" then
            return IfC:new(parse({sexp[1][2]}),
                           parse({sexp[1][3]}), 
                           parse({sexp[1][4]}))
        elseif binop[sexp[1][1]] then
            return BinopC:new(sexp[1][1],
                              parse({sexp[1][2]}), 
                              parse({sexp[1][3]}))
        elseif sexp[1][1] == "lam" then
            return LamC:new(sexp[1][2], parse({sexp[1][3]}))
        elseif len(sexp[1]) == 2 then
            return AppC:new(parse({sexp[1][1]}),
                            parse_args(sexp[1][2]))
        end
	end
end


assert(parse({5}).val == 5, "NumC test")
assert(parse({true}).val == true, "BoolV true test")
assert(parse({false}).val == false, "BoolV false test")
assert(parse({"a"}).val == "a", "IdC test")

if_example = parse({{"if", true, 3, 5}})
assert(if_example.test.val == true and 
	   if_example.t.val == 3 and
       if_example.f.val == 5, "IfC test")

binop_example = parse({{"+", 3, 4}})
assert(binop_example.name == "+" and
       binop_example.left.val == 3 and
       binop_example.right.val == 4, "BinopC test")

lam_example = parse({{"lam", {"a"}, {"+", "a", "a"}}})
assert(lam_example.params[1] == "a" and
       lam_example.body.name == "+" and
       lam_example.body.left.val == "a" and
       lam_example.body.right.val == "a", "LamC test")

appc_example = parse({{"a", {3}}})
assert(appc_example.fun.val == "a" and
       appc_example.args[1].val == 3, "AppC test")

app_lam_example = parse({{{"lam", "a", {"+", "a", 1}}, {3}}})
assert(app_lam_example.fun.params == "a" and
       app_lam_example.fun.body.name == "+" and
       app_lam_example.args[1].val == 3, "app_lam test")


-- Serialize consumes a value and returns a string representing the value
function Serialize(value)
    if value:getType() == "BoolV" then
       if value.val == true then
          return "true"
       else 
          return "false"
       end
    elseif value:getType() == "NumV" then
       return tostring(value.val)
    elseif value:getType() == "CloV" then
      return "procedure"
    else
	   error("Not a Value!")
    end
end

assert(Serialize(BoolV:new(true)) == "true", "BoolV test")
assert(Serialize(NumV:new(3)) == "3", "NumV test")
assert(Serialize(CloV:new(3, 4, 5)) == "procedure", "CloV test")

-- perform_binop takes the name of a binop and its arguments,
-- evaluates and returns the result as a value
function perform_binop(name, left, right)
    leftType = left:getType()
    rightType = right:getType()

    if name == "eq?" then
        if leftType == "CloV" or rightType == "CloV" then
            return BoolV:new(false)
        elseif leftType == rightType and left.val == right.val then
            return BoolV:new(true)
        else
            return BoolV:new(false)
        end
    end
	if leftType ~= "NumV" or 
       rightType ~= "NumV" then
		error("DFLY: invalid input")
	end
    if name == "+" then
		return NumV:new(left.val + right.val)
    elseif name == "*" then
		return NumV:new(left.val * right.val)
    elseif name == "-" then
		return NumV:new(left.val - right.val)
    elseif name == "<=" then
		return BoolV:new(left.val <= right.val)
    elseif name == "/" then
		if right.val == 0 then
			error("DFLY: division by zero")
		end
		return NumV:new(left.val / right.val)
	end
end

assert(perform_binop("+", NumV:new(3), NumV:new(5)).val == 8, "+ test")
assert(perform_binop("-", NumV:new(3), NumV:new(5)).val == -2, "- test")
assert(perform_binop("*", NumV:new(3), NumV:new(5)).val == 15, "* test")
assert(perform_binop("<=", NumV:new(3), NumV:new(5)).val == true, "<= true test")
assert(perform_binop("<=", NumV:new(3), NumV:new(2)).val == false, "<= false test")
assert(perform_binop("/", NumV:new(6), NumV:new(3)).val == 2, "/ test")
assert(perform_binop("eq?", NumV:new(4), NumV:new(4)).val == true, "eq true test")
assert(perform_binop("eq?", NumV:new(5), NumV:new(4)).val == false, "eq false test")
assert(perform_binop("eq?", BoolV:new(true), NumV:new(4)).val == false, "eq false test")
assert(perform_binop("eq?", BoolV:new(true), BoolV:new(true)).val == true, "eq true test")
assert(perform_binop("eq?", BoolV:new(false), BoolV:new(true)).val == false, "eq false test")
assert(perform_binop("eq?", CloV:new(1, 2, 3), CloV:new(1, 2, 3)).val == false, "eq false test")
	

-- interp consumes an exprc, environment and returns a value
function interp(expr, env)
	e_type = expr:getType()

    if e_type == "NumC" then
		return NumV:new(expr.val)
    elseif e_type == "BoolC" then
		return BoolV:new(expr.val)
    elseif e_type == "IdC" then
		if env[expr.val] then
			return env[expr.val]
		else
			error("DFLY: binding not found in environment")
		end
    elseif e_type == "IfC" then
		result = interp(expr.test, env)
		if result:getType() == "BoolV" then
			if result.val == true then
				return interp(expr.t, env)
			else
				return interp(expr.f, env)
			end	
		else
			error("DFLY: if conditional is not a boolean")
		end
    elseif e_type == "BinopC" then
		return perform_binop(expr.name, 
							 interp(expr.left, env),
							 interp(expr.right, env))
    elseif e_type == "LamC" then
        return CloV:new(expr.params, expr.body, env)
    elseif e_type == "AppC" then
        closure = interp(expr.fun, env)
        if len(closure.params) ~= len(expr.args) then
            error("DFLY: wrong arity")
        end
        for i=1,len(expr.args) do
            closure.env[closure.params[i]] = interp(expr.args[i], env)
        end
        return interp(closure.body, closure.env)
    else
	   error("Not a Value!")
    end
end

assert(interp(parse({3})).val == 3, "NumV test") 
assert(interp(parse({true})).val == true, "BoolV true test") 
assert(interp(parse({false})).val == false, "BoolV false test") 
assert(interp(parse({{"if", true, 3, 5}})).val == 3, "IfC true test") 
assert(interp(parse({{"if", false, 3, 5}})).val == 5, "IfC false test") 
assert(interp(parse({{"+", 3, 5}})).val == 8, "BinopC + test") 
assert(interp(parse({{"lam", {"a"}, {"*", 3, "a"}}}), {}).params[1] == "a", "clov test") 
assert(interp(parse({{"lam", {"a"}, {"*", 3, "a"}}}), {}).body.name == "*", "clov test") 
assert(interp(parse({{"lam", {"a"}, {"*", 3, "a"}}}), {}).body.left.val == 3, "clov test") 
assert(interp(parse({{"lam", {"a"}, {"*", 3, "a"}}}), {}).body.right.val == "a", "clov test") 
assert(interp(parse({{{"lam", {"a"}, {"+", "a", 1}}, {3}}}), {}).val == 4, "appC test")
assert(interp(parse({{{"lam", {"a", "b"}, {"*", "a", "b"}}, {3, 4}}}), {}).val == 12, "appC test")


-- top_eval takes in an sexp and returns a string representing the evaluation
function top_eval(sexp)
   return Serialize(interp(parse(sexp), {}))
end

assert(top_eval({3}) == "3", "topeval 3")
assert(top_eval({{"*", 5, 9}}) == "45", "topeval binop")
assert(top_eval({{"if", true, 1, 2}}) == "1", "topeval if")
assert(top_eval({{"if", {"<=", 1, 2}, 1, 2}}) == "1", "topeval if")
assert(top_eval({{{"lam", {"a", "b"}, {"*", "a", "b"}}, {3, 4}}}) == "12", "appC test")
assert(top_eval({{{"lam", {"a", "b"}, {"if", {"eq?", "a", "b"},
                                             "a",
                                             {"*", "a", "b"}}}, {3, 4}}}) == "12", "appC test")
assert(top_eval({{{"lam", {"a", "b"}, {"if", {"eq?", "a", "b"},
                                             "a",
                                             {"*", "a", "b"}}}, {3, 3}}}) == "3", "appC test")
