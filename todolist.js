alert("connected")
var todos= ["get up early"]
var input=prompt("what woud u like to do?")

while(input!== "quit"){

if(input==="list"){
	todos.forEach(function(col){console.log(col)})
}
else if(input==="add"){
  var newTodo= prompt("enter a todo")
  todos.push(newTodo)}
else if(input==="delete"){
	var index= prompt("enter the index which u want to delete")
	todos.splice(index,1)
    console.log("todo deleted")}
	input=prompt("what would u like to do?")
}
alert("you quit the app")
	   
