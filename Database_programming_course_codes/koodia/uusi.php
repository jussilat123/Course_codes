<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla

// jos asiakas painoi luo, lisätään asiakkaan tiedot tietokantaan ja luodaan hänelle asiakas_id
if (isset($_POST['luo'])) {
    // suojataan merkkijonot ennen kyselyn suorittamista
    
	//Jos puhelinnumero on tyhjä, niin sitä ei muuteta kokonaisluvuksi. Tyhjän tapauksessa intval palauttaa 0:n, jota ei haluta.
	//$puhnro = intval($_POST['puhnro']);
	
	$puhnro_query = $_POST['puhnro'];
	if($puhnro_query != ""){
		$puhnro = intval($puhnro_query);
	} else {
		$puhnro = pg_escape_string($puhnro_query);
	}
	
    $nimi = pg_escape_string($_POST['nimi']);
    $sposti = pg_escape_string($_POST['sposti']);
    $osoite = pg_escape_string($_POST['osoite']);

    // luodaan asiakas_id lisäämällä edellisen rivin asiakas_id:seen yksi
	$asiakasid_kysely = "SELECT MAX(Id) from keskustietokanta.Asiakas";
    
    // jos tietokannassa ei ole vielä yhtäkään asiakas_id:tä, aloitetaan numerosta 1
	$tulos = pg_query($asiakasid_kysely);
	
	
	$rivi = pg_fetch_array($tulos);
	
	
    if (!$tulos) {
        $asiakasid = 1;
    }
    else {
        $asiakasid = intval($rivi[0] + 1);
    }
    
	//Lisätään uusi tunnus vain ja jos on annettu nimi
	$tulos_ok = $nimi != "";
	if($tulos_ok){
		
		//Lisätään ensin pakolliset tiedot, eli id ja nimi. Sen jälkeen lisätään muut tiedot jos niitä on annettu.
		$kysely = "INSERT INTO keskustietokanta.Asiakas (id, nimi)
					VALUES ($asiakasid, '$nimi')";
		$tulos = pg_query($kysely);
		//Lisätään puhelinnumero jos se on annettu.
		if($puhnro != ""){
			$paivitys = "UPDATE keskustietokanta.Asiakas SET puhelinnro = $puhnro WHERE Id = $asiakasid";
			$tulos = pg_query($paivitys);
		}
		//Lisätään osoite, jos se on annettu.
		if($osoite != ""){
			$paivitys = "UPDATE keskustietokanta.Asiakas SET osoite = '$osoite' WHERE Id = $asiakasid";
			$tulos = pg_query($paivitys);
		}
		//Lisätään sähköpostiosoite, jos se on annettu.
		if($sposti != ""){
			$paivitys = "UPDATE keskustietokanta.Asiakas SET sahkopostiosoite = '$sposti' WHERE Id = $asiakasid";
			$tulos = pg_query($paivitys);
		}
		
		//Siirrytaan seuraavalle sivulle tunnuksen luomisen jälkeen.
		header('Location: uusi_tunnus_luotu_ilmoitus.php');
	} else {
		echo "Nimi puuttuu! Anna nimi!";
	}
}

// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Uusi käyttäjä</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="uusi.php" method="post">

    <h2>Uusi käyttäjä</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
	    <tr>
    	    <td>Nimi</td>
    	    <td><input type="text" name="nimi" value="" /></td>
	    </tr>
        <tr>
            <td>Sähköpostiosoite</td>
            <td><input type="text" name="sposti" value=""/></td>
        </tr>
        <tr>
            <td>Puhelinnumero</td>
            <td><input type="text" name="puhnro" value=""/></td>
        </tr>
        <tr>
            <td>Osoite</td>
            <td><input type="text" name="osoite" value=""/></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="luo" value="Valmis"/></td>
        </tr>
	</table>

	<br />

</body>
</html>