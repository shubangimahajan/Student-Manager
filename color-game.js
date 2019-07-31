var num=6;
var colors=randomcolors(num)
/*[
	"rgb(255, 0, 0)",
	"rgb(255, 255, 0)",
	"rgb(0, 255, 0)",
	"rgb(0, 255, 255)",
	"rgb(0, 0, 255)",
	"rgb(255, 0, 255)"
]*/
var squares=document.querySelectorAll(".squares")
var message=document.querySelector("#msg")
var rgb=document.querySelector("#rgb")
var h=document.querySelector("h1")
var reset=document.querySelector("#reset")
var level=document.querySelectorAll(".bg")

var pickcolor=function(){
	var col=Math.floor(Math.random()*colors.length);
	return(colors[col]);
}
var pickedcolor=pickcolor()
rgb.textContent=pickedcolor

for (var i = 0; i <level.length; i++) {
     level[i].addEventListener("click",function(){
	 level[0].classList.remove("bgc")
	 level[1].classList.remove("bgc")
	 this.classList.add("bgc")
     if(this.textContent==="EASY"){
     	num=3
     }else{num=6}
	 resetall()
     })
}
function resetall(){
	colors=randomcolors(num)
    pickedcolor= pickcolor()
    rgb.textContent=pickedcolor	
	for(i=0;i<squares.length;i++){
	squares[i].style.display="block"	
	if(colors[i]){
    squares[i].style.backgroundColor=colors[i]}
    else{squares[i].style.display="none"}
        }
    message.textContent=" "
    h.style.backgroundColor="steelblue"}

/*level[0].addEventListener("click",function(){
	 this.classList.add("bgc")
	 level[1].classList.remove("bgc")
     message.textContent=" "
     h.style.backgroundColor="steelblue"
	 num=3
	 colors=randomcolors(num)
	 pickedcolor=pickcolor()
	 for(i=0;i<squares.length;i++){
	 	if(colors[i]){
	 		squares[i].style.backgroundColor=colors[i]}
	 	}
})

level[1].addEventListener("click",function(){
	 this.classList.add("bgc")
	 level[0].classList.remove("bgc")
     message.textContent=" "
     h.style.backgroundColor="steelblue"
	 num=6
	 colors=randomcolors(num)
	 pickedcolor=pickcolor()
	 for(i=0;i<squares.length;i++){
	 		squares[i].style.backgroundColor=colors[i]
	 		squares[i].style.display="block"
	 	}
})*/

for(i=0;i<squares.length;i++){
	squares[i].style.backgroundColor=colors[i];
	squares[i].addEventListener("click",function(){
		var clickedcolor=this.style.backgroundColor;
		//console.log(clickedcolor,pickedcolor)
	if(clickedcolor===pickedcolor){
		message.textContent="correct!!"
		changecolor()
		h.style.backgroundColor=pickedcolor
        reset.textContent="play again!"
		}
		else{this.style.backgroundColor="#232323";
		message.textContent="try again!!"
       }
   })
}

reset.addEventListener("click",function(){
	/*colors=randomcolors(num)
    pickedcolor= pickcolor()
    rgb.textContent=pickedcolor
    for(i=0;i<squares.length;i++){
    squares[i].style.backgroundColor=colors[i]}
    message.textContent=" "
    h.style.backgroundColor="steelblue"*/
    resetall()
    reset.textContent="new colors"
})

var changecolor=function(){
	for(i=0;i<squares.length;i++){
      squares[i].style.backgroundColor=pickedcolor
	}
}


function randomcolors(number){
	var arr= []
	for (var i = 0; i < number; i++) {
		arr.push(generate());
	}
		return(arr);
	}

function generate(){
	var r = Math.floor(Math.random()*256)
	var g = Math.floor(Math.random()*256)
	var b = Math.floor(Math.random()*256)
	var rgbc= "rgb("+ r + ", " +g + ", " + b + ")"
	return rgbc
}		