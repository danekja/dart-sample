/**
 * @author Martin Bydzovsky
 */

// Jednoduchá hashmapa pro uchování aktuálně staženého senzmau uživatelů
var userListData = {}

// všechny operace nad DOMem musí být v jquery navěšeny na DOM-ready event
$(document).ready(function() {
    //stáhneme a vyplníme tabulku uživatelů
    populateTable()

    //navěsíme události na jednotlivé odkazy
    // obyčejný elm.click(function(){}) nestačí, protože by se nezaregistroval pro
    // elementy vytvořené později javascriptem

    $("#userList").on("click", ".linkshowuser", showUserInfo)
    $("#btnAddUser").on("click", addUser)
    $("#userList").on("click", ".linkdeleteuser", deleteUser)


})

// funckce volaná po každé úspěčné operaci (add/delete). Stáhne ze serveru všechny uživatele
// a vyplní je do HTML tabulky
function populateTable() {

    // připravíme si html content pro tabulku
    var tableContent = ''

    // uděláme GET request na naše API
    $.getJSON( '/users', function( data ) {
        // není zde var = upravujeme globální proměnnou definovanou na začátku skriptu
        userListData = {}

        // projdeme odpověď ze serveru a pro každého uživatele vytvoříme řádek tabulky
        for (var i=0; i<data.length; i++) {

            // class linkshowuser a linkdeleteuser = na ty navěsíme onclick
            // Do rel atributu si přidáme ID uživatele
            // budeme ho podle toho pak hledat v userListData a při mazání
            tableContent += "<tr>"
            tableContent += '<td><a href="#" class="linkshowuser" rel="' + data[i]._id + '">' + data[i].username + '</a></td>'
            tableContent += '<td><a href="#" class="btn btn-danger btn-xs linkdeleteuser" rel="' + data[i].id + '">&times; delete</a></td>'
            tableContent += "</tr>"

            //uživatele si uložíme do lokální proměnné (cache)
            userListData[data[i]._id] = data[i]
        }
        // upravíme body tabulky = nahradíme původní obsah aktuálně staženými uživateli
        $("#userList table tbody").html(tableContent)
    })
}


// Obsluha události kliknutí na jméno uživatele - zobrazíme detaily do levé tabulky
function showUserInfo(event) {

    // zastavíme defaultní akci (a href=# by skočilo na HTML začátek stránky)
    event.preventDefault()

    // z rel atribudu linku si vytáhneme id uživatele
    var id = $(this).attr('rel')

    // najdeme ho v lokální cachi
    var user = userListData[id]

    // vyplníme jednotlivé informace u tomto uživateli
    $("#userInfoUsername").text(user.username)
    $("#userInfoFullname").text(user.name)
    $("#userInfoEmail").text(user.email)
}

// Obsluha události new user
function addUser(event) {

    // připravíme si objekt nového uživatele který pošleme na server
    var newUser = {
        username: $("#inputUserName").val(),
        email: $("#inputUserEmail").val(),
        name: $("#inputUserFullname").val(),
    }

    //zkontrolujeme že jsou všechna pole vyplněna
    for (var prop in newUser)
        if(!newUser[prop])
        //return ukončí celou funkci..
            return alert("Please fill in all fields")

    //uděláme AJAXem HTTP POST na server s daty nového uživatele
    $.ajax({
        type: "POST",
        data: newUser,
        url: "/users"
    }).done(function( response ) {
        if (response.error)
            return alert("Error from server: " + response.error)

        //vyprázdníme všechna input pole
        $("#addUser input").val("")

        //znovy vyplníme HTML tabulku s uživateli
        populateTable()
    })
}

// Obsluha události delete user
function deleteUser(event) {

    // zastavíme defaultní akci (a href=# by skočilo na HTML začátek stránky)
    event.preventDefault()

    // opravdu chceme mazat? Jednoduchý JS popup
    var confirmation = confirm("Are you sure you want to delete this user?")

    if (confirmation === false) {
        //return ukončí volání delého deleteUser
        return false
    }

    var userId = $(this).attr("rel")
    //uděláme AJAXem HTTP DELETE požadavek na server
    $.ajax({
        type: "DELETE",
        url: "/users/" + userId
    }).done(function( response ) {
        if (response.error)
            return alert("Error: " + response.error)

        // aktualizujeme tabulku po úspěšném smazání
        populateTable()

    })
}
