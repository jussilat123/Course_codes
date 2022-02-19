<?php
// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla

if($_GET){
	$kayttaja = $_GET['user'];
	$title = "Divarin $kayttaja ylläpitäjän lomake";       
    }else{
	$title = "Käyttäjää ei ole määritelty!";
      echo "Url has no user";
    }
	

// jos asiakas painoi luo, lisätään asiakkaan tiedot tietokantaan ja luodaan hänelle asiakas_id
if (isset($_POST['luo_teos'])) {
    // suojataan merkkijonot ennen kyselyn suorittamista
    $teos_tekija = pg_escape_string($_POST['teos_tekija']);
    $teos_nimi = pg_escape_string($_POST['teos_nimi']);
    $teos_tyyppi = pg_escape_string($_POST['teos_tyyppi']);
	$teos_luokka = pg_escape_string($_POST['teos_luokka']);
	$teos_isbn = pg_escape_string($_POST['teos_isbn']);
	
	//Luodaan teos_id lisäämällä edellisen rivin id:hen yksi. Sama id keskustietokantaan ja divarin tietokantaan.
	$teos_id_kysely_keskustietokanta = "SELECT max(Id) FROM keskustietokanta.Teos";
    
    // jos tietokannassa ei ole vielä yhtäkään teosta, aloitetaan numerosta 1
	$tulos = pg_query($teos_id_kysely_keskustietokanta);
	$rivi = pg_fetch_array($tulos);
    if (!$tulos) {
        $teossid_keskustietokanta = 1;
    }
    else {
        $teossid_keskustietokanta = intval($rivi[0] + 1);
    }
    
	
	//Teokselle on annettava nimi, muuten teosta ei lisätä.
	if($teos_nimi == ""){
		echo "Teokselle on annettava nimi!";
	} else {
		
		//Lisätään ensin ID ja teoksen nimi. Sitten lisätään muut tiedot, jos niitä on annettu.
		$kysely_keskus = "INSERT INTO keskustietokanta.Teos (id, nimi)
					VALUES ($teossid_keskustietokanta, '$teos_nimi')";
		$tulos_keskus = pg_query($kysely_keskus);
		
		//Lisätään ensin ID ja teoksen nimi. Sitten lisätään muut tiedot, jos niitä on annettu.
		$kysely_divari1 = "INSERT INTO divari1.d1teos (id, nimi)
					VALUES ($teossid_keskustietokanta, '$teos_nimi')";
		$tulos_divari1 = pg_query($kysely_divari1);
		
		//Lisätään teos 
		if($teos_tekija != ""){
			//keskustietokanta
			$paivitys = "UPDATE keskustietokanta.Teos SET tekija = '$teos_tekija' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
			
			//divari 1
			$paivitys = "UPDATE divari1.d1teos SET tekija = '$teos_tekija' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
		}
		if($teos_tyyppi != ""){
			//keskustietokanta
			$paivitys = "UPDATE keskustietokanta.Teos SET tyyppi = '$teos_tyyppi' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
			
			//divari 1
			$paivitys = "UPDATE divari1.d1teos SET tyyppi = '$teos_tyyppi' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
		}
		if($teos_luokka != ""){
			//keskustietokanta
			$paivitys = "UPDATE keskustietokanta.Teos SET luokka = '$teos_luokka' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
			
			//divari 1
			$paivitys = "UPDATE divari1.d1teos SET luokka = '$teos_luokka' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
		}
		if($teos_isbn != ""){
			//keskustietokanta
			$paivitys = "UPDATE keskustietokanta.Teos SET isbn = '$teos_isbn' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
			
			//divari 1
			$paivitys = "UPDATE divari1.d1teos SET isbn = '$teos_isbn' WHERE Id = $teossid_keskustietokanta";
			$tulos = pg_query($paivitys);
		}
		echo "Teos lisätty! ID on: $teossid_keskustietokanta";
	}
	
	
		
}

if(isset($_POST['luo_nide'])){
	// suojataan merkkijonot ennen kyselyn suorittamista ja tarkistetaan onko syötteet kelvollisia.
	
	$tulos_ok = true; //tarkistaa onko syöte ok, muutetaan epätodeksi jos yhdessäkin kohdassa on väärä syöte
	
	if(!$kayttaja){
		echo nl2br ("Käyttäjää ei ole ilmoitettu! \n");
		$tulos_ok = false;
	}
		
	
	//Tarkistetaan onko teoksen id annettu ja onko sitä olemassa keskustietokannassa
	$nide_teos_id_query = $_POST['nide_teos_id'];
	if($nide_teos_id_query != ""){
		$nide_teos_id = intval($nide_teos_id_query);
		
		//Tarkistetaan onko tätä id:tä olemassa teos-taulussa.
		$teos_id_kysely = "SELECT id FROM keskustietokanta.Teos WHERE id = $nide_teos_id";
		$teos_id_kysely_tulos = pg_query($teos_id_kysely);
		$teos_id_kysely_rivi = pg_fetch_array($teos_id_kysely_tulos);
		if(!$teos_id_kysely_rivi){
			echo nl2br ("Teosta $nide_teos_id ei ole tietokannassa! \n");
			$tulos_ok = false;
		}
	} else {
		echo nl2br ("Teoksen ID on annettava! \n");
		$tulos_ok = false;
	}
	
	
	//Tarkistetaan onko niteen paino annettu ja onko se positiviinen luku
	$nide_paino_query = $_POST['nide_paino'];
	if($nide_paino_query != ""){
		$nide_paino = floatval($nide_paino_query);
		if($nide_paino <= 0){
			echo nl2br ("Niteen painon on oltava positiivinen luku! \n");
			$tulos_ok = false;
		}
	} else {
		$tulos_ok = false;
		echo nl2br ("Niteen paino on annettava! \n");
	}
	
	//Tarkistetaan onko niteen hinta annettu ja onko se nolla tai positiivinen luku
	$nide_hinta_query = $_POST['nide_hinta'];
	if($nide_hinta_query != ""){
		$nide_hinta = floatval($nide_hinta_query);
		if($nide_hinta < 0){
			echo nl2br ("Niteen hinnan on oltava nolla tai positiivinen luku! \n");
			$tulos_ok = false;
		}
	} else {
		$tulos_ok = false;
		echo nl2br ("Niteen hinta on annettava! \n");
	}
	
	//Tarkistetaan onko sisäänostohinta positiivinen luku tai nolla, voi olla tyhjä
	$nide_sisaanostohinta_query = $_POST['nide_sisaanostohinta'];
	if($nide_sisaanostohinta_query != ""){
		$nide_sisaanostohinta = floatval($nide_sisaanostohinta_query);
		if($nide_sisaanostohinta < 0){
			echo nl2br ("Niteen sisaanostohinnan on oltava positiivinen luku tai nolla! \n");
			$tulos_ok = false;
		}
	} else {
		$nide_sisaanostohinta = pg_escape_string("");
	}
	
	//Tarkistetaan, että niteen tila ei ole tyhjä
	$nide_tila_query = $_POST['nide_tila'];
	if($nide_tila_query != ""){
		//Tähän voisi lisätä tarkistukset onko tilan syöte muuten ok
		$nide_tila = pg_escape_string($nide_tila_query);
	} else {
		echo nl2br ("Niteen tila on annettava! \n");
		$tulos_ok = false;
	}
	
	//Luodaan teos_id lisäämällä edellisen rivin id:hen yksi.
	$nide_id_kysely = "SELECT max(Id) FROM keskustietokanta.nide";
    
    // jos tietokannassa ei ole vielä yhtäkään teosta, aloitetaan numerosta 1
	$tulos = pg_query($nide_id_kysely);
	$rivi = pg_fetch_array($tulos);
    if (!$tulos) {
        $nide_id = 1;
    }
    else {
        $nide_id = intval($rivi[0] + 1);
    }
	
	//Lisätään uusi nide jos syötteet olivat ok.
	if($tulos_ok){
		$kysely = "INSERT INTO keskustietokanta.Nide (id, teos_id, paino, hinta, tila, divari_id)
					VALUES ($nide_id, $nide_teos_id, $nide_paino, $nide_hinta, '$nide_tila', $kayttaja)";
		$tulos = pg_query($kysely);
		
		$kysely = "INSERT INTO divari1.d1nide (id, teos_id, paino, hinta, tila)
					VALUES ($nide_id, $nide_teos_id, $nide_paino, $nide_hinta, '$nide_tila')";
		$tulos = pg_query($kysely);
		
		//Lisätään sisäänostohinta, jos se on annettu.
		if($nide_sisaanostohinta != ""){
			$paivitys = "UPDATE keskustietokanta.Nide SET Sisaanostohinta = $nide_sisaanostohinta WHERE Id = $nide_id";
			$tulos = pg_query($paivitys);
			
			$paivitys = "UPDATE divari1.d1nide SET Sisaanostohinta = $nide_sisaanostohinta WHERE Id = $nide_id";
			$tulos = pg_query($paivitys);
		}
		
		echo nl2br ("Nide lisätty onnistuneesti tietokantaan! \n");
		echo nl2br ("Nide ID: $nide_id \n Teos ID: $nide_teos_id \n Niteen paino: $nide_paino \n Niteen hinta: $nide_hinta \n");
		echo nl2br ("Niteen tila: $nide_tila \n Divari ID: $kayttaja \n Sisäänostohinta: $nide_sisaanostohinta");
	}
}


// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Lisää teos tai nide</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
	<form action="lisaa_teos_muut_divarit.php<?php echo '?user='.$kayttaja?>" method="post">
    <h2><?php echo $title; ?></h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>
	<h2> Lisää Teos </h2>
	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
        <tr>
            <td>Tekija</td>
            <td><input type="text" name="teos_tekija" value=""/></td>
        </tr>
        <tr>
            <td>Nimi</td>
            <td><input type="text" name="teos_nimi" value=""/></td>
        </tr>
        <tr>
            <td>Tyyppi</td>
            <td><input type="text" name="teos_tyyppi" value=""/></td>
        </tr>
		<tr>
    	    <td>Luokka</td>
    	    <td><input type="text" name="teos_luokka" value="" /></td>
	    </tr>
		<tr>
    	    <td>ISBN</td>
    	    <td><input type="text" name="teos_isbn" value="" /></td>
	    </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="luo_teos" value="Lisaa teos"/></td>
        </tr>
	</table>


	<?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>
	<h2> Lisää Nide </h2>
	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
		<tr>
    	    <td>Teos_id</td>
    	    <td><input type="text" name="nide_teos_id" value="" /></td>
	    </tr>
		<tr>
    	    <td>Paino</td>
    	    <td><input type="text" name="nide_paino" value="" /></td>
	    </tr>
		<tr>
    	    <td>Hinta</td>
    	    <td><input type="text" name="nide_hinta" value="" /></td>
	    </tr>
		<tr>
    	    <td>Sisäänostohinta</td>
    	    <td><input type="text" name="nide_sisaanostohinta" value="" /></td>
	    </tr>
		<tr>
    	    <td>Tila</td>
    	    <td><input type="text" name="nide_tila" value="" /></td>
	    </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="luo_nide" value="Lisaa nide"/></td>
        </tr>
	</table>
	
	
	<h2> Tulosta tietokannan teokset </h2>
		<tr>
            <td></td>
            <td><input type="submit" name="tulosta_teokset" value="Tulosta teokset"/>
        </tr>
	
	<?php  
	$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

	if (!$yhteys = pg_connect($y_tiedot))
		die("Tietokantayhteyden luominen epäonnistui.");
	
	//Tulostetaan teos-taulun sisältö
	if(isset($_POST['tulosta_teokset'])){
		$kysely = "SELECT id,tekija,nimi,tyyppi,luokka,isbn FROM keskustietokanta.Teos";
		$tulos = pg_query($kysely);
		$tulosTaulu = pg_fetch_all($tulos);
		echo '<table>
			<tr>
			<td>Id</td>
			<td>Tekija</td>
			<td>Nimi</td>
			<td>Tyyppi</td>
			<td>Luokka</td>
			<td>ISBN</td>
			</tr>';
		foreach($tulosTaulu as $taulu)
		{
			echo '<tr>
				<td>'. $taulu['id'].'</td>
				<td>'. $taulu['tekija'].'</td>
				<td>'. $taulu['nimi'].'</td>
				<td>'. $taulu['tyyppi'].'</td>
				<td>'. $taulu['luokka'].'</td>
				<td>'. $taulu['isbn'].'</td>
			</tr>';
		}
		echo '</table>';
}

// suljetaan tietokantayhteys

pg_close($yhteys);
	
	?>
	<br />

</body>
</html>