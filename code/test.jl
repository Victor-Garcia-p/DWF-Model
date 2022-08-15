#script from https://github.com/JuliaPlots/Makie.jl/issues/521

using CairoMakie

θdata = 0:0.1:2π
rdata = 20 .* sin.(2*θdata)

rs = range(1, round(maximum(rdata)), length = 4)
θs = 0:π/4:2π
rborder = maximum(rs) * 1.10

f = Figure()
ax = Axis(f[1, 1], aspect = 1.0)

for r in rs
    lines!(ax, Circle(Point2f(0), r), color = :lightgray)
end

lines!(ax, Circle(Point2f(0), rborder), color = :lightgray)

radiallines = zeros(Point2f, 2 * length(θs))

for (i, θ) in enumerate(θs)
    radiallines[i*2] = Point2f(rborder * cos(θ), rborder * sin(θ))
end

linesegments!(ax, radiallines, color = :lightgray)

for r in rs
    text!("$(r)", position = (r, 0), align = (:center, :bottom))
end

for θ in θs[1 : end-1]
    offset = rborder * 0.1
    xpos = (rborder + offset) * cos(θ)
    ypos = (rborder + offset) * sin(θ)
    text!("$(Int64(θ * 180/π))°", position = (xpos, ypos), align = (:center, :center))
end

lines!(ax, rdata .* cos.(θdata), rdata .* sin.(θdata))
hidespines!(ax)
hidedecorations!(ax)

display(f)
