<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla
session_start();
// jos asiakas painoi 'Uusi käyttäjä', siirrytään luomaa uutta käyttäjää
if (isset($_POST['uusi'])) {
    header('Location: uusi.php');
}
    
// jos asiakas painoi 'Kirjaudu sisään', koitetaan sisäänkirjautumista
if (isset($_POST['kirjautuminen'])) {

	
    $asiakasid  = intval($_POST['asiakasid']);
	
    // katsotaan, löytyykö asiakasid tietokannasta
    $tulos = pg_query("SELECT Id FROM keskustietokanta.Asiakas WHERE Id=$asiakasid");
	$rivi = pg_fetch_array($tulos);
	
    // jos ei löydy, ilmoitetaan virheestä
    if (!$rivi) {
        echo "Asiakas-id:tä ei löytynyt, tarkista syöte tai luo uusi käyttäjä.\n";
    }    
    // jos löytyy, siirrytään seuraavalle sivulle kirjautuneena
    else {
        $_SESSION['asiakasid'] = $_POST['asiakasid'];
        header('Location: haku.php');
    }
}

// jos käyttäjä painoi 'Kirjaudu ylläpitäjänä', siirrytään ylläpitäjän kirjautumiseen
if (isset($_POST['yllapitaja'])) {
    header('Location: yllapitajakirjautuminen.php');
}


    

// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Kirjautuminen</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="kirjautuminen.php" method="post">

    <h2>Kirjautuminen</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
	    <tr>
    	    <td>Asiakas-id</td>
    	    <td><input type="text" name="asiakasid" value="" /></td>
	    </tr>
        <tr><td></td><td><input type="submit" name="kirjautuminen" value="Kirjaudu sisään"/></td></tr>
        <tr><td></td><td><input type="submit" name="uusi" value="Uusi käyttäjä"/></td></tr>
        <tr><td></td><td><input type="submit" name="yllapitaja" value="Kirjaudu ylläpitäjänä"/></td></tr>
	</table>

	<br />

</body>
</html>
