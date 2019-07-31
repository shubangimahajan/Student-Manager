var p1dsp=document.querySelector("#p1display")
var maxdsp=document.getElementById("max")
var p2dsp=document.getElementById("p2display")
var p1b=document.getElementById("p1")
var p2b=document.getElementById("p2")
var resetb=document.getElementById("reset")
var max=document.querySelector("input")


//p1dsp.style.color="pink"
max.value=5
var limit=max.value

max.addEventListener("change",function(){
	maxdsp.textContent=Number(max.value)
    limit=Number(max.value)
}
)

// maxdsp.textContent=max
// maxdsp.textContent=max.textContent

var p1score=0
var p2score=0
console.log(p1score)
p1b.addEventListener("click",function(){
	if(p1score!=limit && p2score!=limit){
	p1score++
	p1dsp.textContent=p1score}
	if(p1score==limit){p1dsp.classList.add("style")}
	
})
p2b.addEventListener("click",function(){
    if(p2score!=limit && p1score!=limit){
	p2score++
	p2dsp.textContent=p2score
	}if(p2score==limit){p2dsp.classList.add("style")}
})

resetb.addEventListener("click",function(){
	p1dsp.textContent=0
	p2dsp.textContent=0
    p1score=0
    p2score=0
	p1dsp.classList.remove("style")
	p2dsp.classList.remove("style")
    var max=document.querySelector("input")

})

	
	


