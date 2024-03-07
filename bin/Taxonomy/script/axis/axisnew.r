axisnew<-function(side=2,ylim=ylim){
	print(ylim)
	ylim=c(ylim[1],ylim[2]*1.25)
	y=axis(side=side,ylim=ylim,labels=F,tick=F)
	max=ylim[2]/1.5
	print(y)
	print(length(y))
	for(i in 2:length(y) ){
		if(max>y[i-1] && max<=y[i]){
				print(max)
					print(i)
				print(y[i-1])
				return(y[1:i] )

		}
	}
}
