<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla

// jos käyttäjä painoi 'Uusi ylläpitäjä', siirrytään luomaa uutta ylläpitäjäkäyttäjää
if (isset($_POST['uusi_yllapitaja'])) {
    header('Location: uusi_yllapitaja.php');
}
    
// jos käyttäjä painoi 'Kirjaudu sisään', koitetaan sisäänkirjautumista
if (isset($_POST['yllapitaja_kirjautuminen'])) {

	
    $yllapitajaid  = intval($_POST['yllapitajaid']);
	
    // katsotaan, löytyykö yllapitajaid tietokannasta
    $tulos = pg_query("SELECT Id FROM keskustietokanta.Yllapitaja WHERE Id=$yllapitajaid");
	$rivi = pg_fetch_array($tulos);
	
    // jos ei löydy, ilmoitetaan virheestä
    if (!$rivi) {
        echo "Ylläpitäjä-id:tä ei löytynyt, tarkista syöte tai luo uusi käyttäjä.\n";
    }    
    // jos löytyy, siirrytään seuraavalle sivulle kirjautuneena
    else {
        // siirrytään lisaa_teos-sivulle ja annetaan kirjautujan divari
		
		$divari_id_kysely = "SELECT keskustietokanta.divariid.DIVARI_ID
								FROM keskustietokanta.yllapitaja LEFT OUTER JOIN keskustietokanta.divariid ON 
								(keskustietokanta.divariid.Divari_nimi = keskustietokanta.yllapitaja.divari)
								WHERE keskustietokanta.yllapitaja.id = $yllapitajaid";
		
		$divari_tulos = pg_query($divari_id_kysely);
		$rivi_divari_id = pg_fetch_array($divari_tulos);
		$divari_id = $rivi_divari_id[0];
		if($divari_id = 2){
			//Mennään keskustietokantaan tässä
			header("Location: lisaa_teos_keskustietokanta.php?user=".$divari_id);
		}else {
			header("Location: lisaa_teos_muut_divarit.php?user=".$divari_id);
		}
		
    }
}
    

// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Ylläpitäjän kirjautuminen</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="yllapitajakirjautuminen.php" method="post">

    <h2>Ylläpitäjän kirjautuminen</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
	    <tr>
    	    <td>Ylläpitäjä-id</td>
    	    <td><input type="text" name="yllapitajaid" value="" /></td>
	    </tr>
        <tr><td></td><td><input type="submit" name="yllapitaja_kirjautuminen" value="Kirjaudu sisään"/></td></tr>
        <tr><td></td><td><input type="submit" name="uusi_yllapitaja" value="Uusi ylläpitäjä"/></td></tr>
	</table>

	<br />

</body>
</html>
