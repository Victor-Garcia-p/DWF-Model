#=
Info: This file creates a boxplot that represents the maximum values of wind each day 
during the event of DWF of 2012-2013 at different intervals.

Three intervals are analyzed:
-Precondicionament: It goes from 08-16-2012 to 01-15-2013 (note that there is no data in January)
-Convection: It goes from 01-15-2013 to 03-21-2013 
-Analysis of error: From 02-01 to 07-02, is the period used to make the simulations of the 
analysis of errors in the TFG

Input: Nothing (the data is on variables "w_prec" and "w_con")
Output: The box plot of the TFG


References: Data of wind max values from Lion Buoy 61002
https://www.geographic.org/global_weather/france/lion_buoy_61002_996170_99999.html
=#

using DrWatson
@quickactivate

using CairoMakie

w_prec=[
20.83	,
8.06	,
9.21	,
12.77	,
13.81	,
13.81	,
18.3	,
19.45	,
16.11	,
37.98	,
35.56	,
23.02	,
19.45	,
14.96	,
39.13	,
43.61	,
47.18	,
33.26	,
39.13	,
29.92	,
21.86	,
19.45	,
8.06	,
8.06	,
9.21	,
11.39	,
10.24	,
32.22	,
47.18	,
41.31	,
40.28	,
12.77	,
8.06	,
17.26	,
31.07	,
34.41	,
16.11	,
12.77	,
20.83	,
39.13	,
26.35	,
29.92	,
16.11	,
21.86	,
36.71	,
21.86	,
23.02	,
19.45	,
16.11	,
16.11	,
9.21	,
11.39	,
31.07	,
26.35	,
28.88	,
17.26	,
31.07	,
27.5	,
47.18	,
36.71	,
26.35	,
27.5	,
32.22	,
34.41	,
25.32	,
28.88	,
12.77	,
9.21	,
11.39	,
18.3	,
25.32	,
58.57	,
55.24	,
43.61	,
60.76	,
48.33	,
18.3	,
17.26	,
17.26	,
18.3	,
29.92	,
37.98	,
33.26	,
12.77	,
20.83	,
20.83	,
25.32	,
35.56	,
34.41	,
23.02	,
16.11	,
18.3	,
23.02	,
16.11	,
17.26	,
25.32	,
26.35	,
13.81	,
16.11	,
13.81	,
20.83	,
31.07	,
56.39	,
54.09	,
44.77	,
34.41	,
44.77	,
26.35	,
47.18	,
33.26	,
35.56	,
39.13	,
47.18	,
34.41	,
34.41	,
27.5]

w_cond = 
[21.86,
13.81	,
44.77	,
47.18	,
35.56	,
26.35	,
37.98	,
46.03	,
36.94	,
37.98	,
27.73	,
34.41	,
39.13	,
40.28	,
33.26	,
33.26	,
24.17	,
11.39	,
20.83	,
12.77	,
13.81	,
14.96	,
19.68	,
46.03	,
44.88	,
34.41	,
29.92	,
17.26	,
27.73	,
36.94	,
28.88	,
10.24	,
32.22	,
40.28	,
39.13	,
18.3	,
28.88	,
14.96	,
17.26	,
18.3	,
29.92	,
51.9	,
52.94	,
48.33	,
28.88	,
26.35	,
27.73	,
17.26	,
32.22	,
20.83	,
]

#Create x values of observations to do the box plot
xs=vcat(fill(1,116),    
fill(2,50),fill(3,7))

#w_cond[2:8] is the 7 days of the analysis of error in february
ys=vcat(w_prec,w_cond,w_cond[2:8])

f = Figure()

ax = Axis(f[1, 1], ylabel="Velocitat del vent màxima (m/s)",
yminorticksvisible = true,
xticks = (1:1:3,["Precondicionament
08-16 a 01-15
(n=117)",

"Convecció
15-01 a 02-01 
(n=59)","Anàlisis del error 
02-01 a 02-07
(n=7)"]))
#

boxplot!(ax,xs, ys,show_outliers=true, show_notch = false, color =  color = xs,colormap=[:lightcoral,:aqua,:aquamarine1])
scatter!(xs, ys,color=(:grey32,0.5))

display(f)