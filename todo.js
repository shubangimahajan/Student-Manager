/*alert("connected")*/

var todo =["go to bath"];
var input=prompt("what woud u like to do?");

while(input!== "quit"){
    if(input==="list"){
	  todo.forEach(function(el,i){
      console.log(i + ": " + el)})};
    if(input==="delete"){
	 i=prompt("enter the index of todo to b deleted");	
     todo.splice(i,1);
	alert("todo deleted");}
    if(input==="add"){
      var newtodo = prompt("enter a todo");
	  todo.push(newtodo);
	  console.log("todo added");}
	input=prompt("what would u like to do");
}
console.log("ok... u quit the app");	
	  
 
 
 