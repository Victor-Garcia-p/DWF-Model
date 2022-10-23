function fun1(t)
    for i=1:1000
        for j=1:1000
            t+=(0.5)^t+(0.3)^(t-1);
        end
    end
    return t
end
function fun2(t)
    for i=1:1000
        for j=1:1000
            t+=(0.5)^t;
        end
    end
    return t
end
function fun3(r)
    for i=1:1000
        for j=1:1000
            r = (r + 5)/r;
        end
    end
    return r
end

function main()
    a = [3, 2.5, 3.0]
    f = [fun1, fun2, fun3]
    for i in 1:3
        a[i] = f[i](a[i])
    end
    return a
end



