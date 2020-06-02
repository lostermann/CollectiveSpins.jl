using JLD, PyPlot, PyCall
anim = pyimport("matplotlib.animation")

fig = figure(figsize=(5, 5))

function make_frame(k)
	cla()
	
	X = load("$(k+1).jld", "X")
	Y = load("$(k+1).jld", "Y")
	I_profile = load("$(k+1).jld", "I_profile")
	Geo = load("$(k+1).jld", "Geo")
	N1 = load("$(k+1).jld", "N1")
	alpha_ = load("$(k+1).jld", "alpha_")

	contourf(X, Y, I_profile, 100,cmap="viridis")
	for i = 1:N1+N1
		plot(Geo[i][1],Geo[i][2],"wo",markersize=6,alpha=0.2+0.8*alpha_[i])
	end
end

myanim = anim.FuncAnimation(fig, make_frame, frames=100, interval=100)
myanim.save("test2.mp4", bitrate=-1, extra_args=["-vcodec", "libx264", "-pix_fmt", "yuv420p"])
