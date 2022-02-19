<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla

// jos käyttäjä painoi luo, lisätään ylläpitäjän tiedot tietokantaan ja luodaan hänelle ylläpitäjän id
if (isset($_POST['luo_yllapitaja'])) {
    // suojataan merkkijonot ennen kyselyn suorittamista
    
    $nimi = pg_escape_string($_POST['nimi']);
    $divari = pg_escape_string($_POST['divari']);

    // luodaan yllapitaja_id lisäämällä edellisen rivin yllapitaja_id:seen yksi
	$yllapitajaid_kysely = "SELECT MAX(Id) from keskustietokanta.yllapitaja";
    
    // jos tietokannassa ei ole vielä yhtäkään yllapitaja_id:tä, aloitetaan numerosta 1
	//$tulos = pg_query($divariid_kysely);
	$tulos = pg_query($yllapitajaid_kysely);
	
	
	$rivi = pg_fetch_array($tulos);
	
	
    if (!$tulos) {
        $yllapitajaid = 1;
    }
    else {
        $yllapitajaid = intval($rivi[0] + 1);
    }
    
    
	//Lisätään uusi tunnus vain jos on annettu nimi ja oikea divari
	$divarit = array('D1','D2','Keskustietokanta','Lassen lehti','Galleinn Galle');
	$tulos_ok = (($nimi != "") && (in_array($divari, $divarit)));
	if($tulos_ok){
		
		//Lisätään tiedot tietokantaan
		$kysely = "INSERT INTO keskustietokanta.Yllapitaja (id, nimi, divari)
					VALUES ($yllapitajaid, '$nimi', '$divari')";
		$paivitys = pg_query($kysely);
		//Siirrytaan seuraavalle sivulle tunnuksen luomisen jälkeen.
		header('Location: yllapitajakirjautuminen.php');
	} else {
		echo "Käyttäjän nimi puuttuu tai divarin nimi on virheellinen!";
	}
}

// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Uusi ylläpitäjä</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="uusi_yllapitaja.php" method="post">

    <h2>Uusi ylläpitäjä</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
	    <tr>
    	    <td>Nimi</td>
    	    <td><input type="text" name="nimi" value="" /></td>
	    </tr>
            <td>Divari</td>
            <td><input type="text" name="divari" value=""/></td>
        </tr>
            <td></td>
            <td><input type="submit" name="luo_yllapitaja" value="Valmis"/></td>
        </tr>
	</table>

	<br />

</body>
</html>
