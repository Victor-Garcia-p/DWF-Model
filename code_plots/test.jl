
function load_AOI(x,y,z,t,first=1,last=2)
    global T_plot=Any[]
    for i in first:last
        T_interest=T[i].data[x,y,z,t]
    
        #fig = Figure(resolution=(1200, 800))
        #ax = Axis(fig[1, 1], ylabel = "Depth (m)", xlabel = "Temperature(C)")
        #sca=scatter!(ax, T_interest[1], zT)
        push!(T_plot,T_interest)
    end
end


##INTENTO
function load_test(x,y,z,t,first=1,last=2,name)
    expr=Any[]
    
    for j in first:last
        # user-supplied expression
        loop = :(i[j].data[x,y,z,t])
        push!(expr,loop)
    end

    # splice into function body
    testo = @eval function (x,y,z,t,name)
    i = name
    $expr
    end
end

##
#Create a new variable with a name

function test(x,y,z,t,name)
    y = Symbol(nam*"_test")
    eval(:($y = 6))

end

test(32,2,:,41,T)


##
expr=Any[]

function test(x,y,z,t)

    for j in 1:2
        loop = :(i[$j].data[x,y,z,t])



        push!(expr,loop)
    end
    
end

test(32,2,:,41)

##
e=:Expr[]

##
for j in 1:2
    loop = :(i[$j].data[x,y,z,t])
    push!(expr,loop)
end



##
function test(x,y,z,t,name)
    for j in 1:3
        expr = :(i[j].data[x,y,z,t])

        testo = @eval function te(x,y,z,t,name)
            i = name
            $expr
        end
    end
end

test(32,2,:,41,T)


##
# user-supplied expression


for j in 1:2
    loop = :(i[$j].data[x,y,z,t])
    push!(expr,loop)
end












##
nam="S"

y = Symbol(nam*"_test")
eval(:($y = Any[]))




##
Eⁱ=Any[]
for i in 2:10
    push!(Eⁱ,rmsd(T_plot[1], T_plot[i]))
end

##
function load_AOI(x,y,z,t,first=1,last=2,variable="T")
    if variable=="T"
        global T_plot=Any[]
        for i in first:last
        T_interest=T[i].data[x,y,z,t]
    
        push!(T_plot,T_interest)
        end
    end

    if variable=="S"
        global S_plot=Any[]
        for i in first:last
        S_interest=Sa[i].data[x,y,z,t]
    
        push!(S_plot,S_interest)
        end
    end

    
    if variable=="w"
        global w_plot=Any[]
        for i in first:last
        w_interest=w[i].data[x,y,z,t]
    
        push!(w_plot,w_interest)
        end
    end
end

load_AOI(32,2,:,41,1,1,"w")
