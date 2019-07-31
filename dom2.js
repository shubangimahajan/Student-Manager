var button=document.querySelector("button")
 button.addEventListener("click",function(){
    document.body.classList.toggle("purple")});


var p = document.querySelectorAll("h1")[1]
var button1=document.querySelectorAll("button")[1]

/*METHOD 1  
var tf=true
 button1.addEventListener("click",function(){
    if(tf){
        p.textContent="hello again"; tf=false;}
     else {p.textContent="bye"; tf=true}});*/

/*METHOD 2
 button1.addEventListener("click",function(){
    if(p.textContent=="bye"){
        p.textContent="hello again"}
     else {p.textContent="bye"}});*/ 	

/*METHOD 3 */

function ctext(){
    if(p.textContent=="bye"){
        p.textContent="hello again"}
     else if(p.textContent="hello agaian"){p.textContent="bye"}}	 
 button1.addEventListener("click",ctext);	 