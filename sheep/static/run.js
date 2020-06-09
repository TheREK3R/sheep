packetNum = 20;

function get_table(){
    var Http = new XMLHttpRequest();
    Http.open("GET", "/packets/"+packetNum);
    Http.send();

    Http.onreadystatechange=function(){
        if(this.readyState == 4 && this.status == 200){
            if (Http.responseText === "") return;
            fill_table(JSON.parse(Http.responseText))
        }
    }
}

function fill_table(arr){
    var table = document.getElementById("t1");
    for(var i = table.rows.length-1; i > 0 ; i--){
        table.deleteRow(i)
    }

    for(var i = 0; i < packetNum; i++){
        var row = table.insertRow(i+1)
        if(arr[i]){
            let c;
            c = row.insertCell(0);
            c.innerText = `${arr[i]["id.resp_h"]}:${arr[i]["id.resp_p"]}`;
            c.id = "ser";

            c = row.insertCell(1);
            c.innerText = arr[i].username;
            c.id = "uid"

            c = row.insertCell(2);
            c.innerText = arr[i].password;
            c.id = "pass"
            
            c = row.insertCell(3);
            c.innerText = arr[i].where_found;
            c.id = "content"
        }

        else{
            let c;
            c = row.insertCell(0);
            c.id = "ser";

            c = row.insertCell(1);
            c.id = "uid"

            c = row.insertCell(2);
            c.id = "pass"
            
            c = row.insertCell(3);
            c.id = "content"
        }
    }
};

window.onload=get_table()
window.setInterval(get_table, 5000)
