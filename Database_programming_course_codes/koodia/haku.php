<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla
session_start();
// jos asiakas painoi hae, aletaan suorittamaan hakua
if (isset($_POST['hae'])) {
    // suojataan merkkijonot ennen kyselyn suorittamista
    $nimi = pg_escape_string($_POST['nimi']);
    $tekija = pg_escape_string($_POST['tekija']);
    $tyyppi = pg_escape_string($_POST['tyyppi']);
    $luokka = pg_escape_string($_POST['luokka']);
    

    // jos nimi on annettu, lähdetään tekemään hakua sen perusteella
    if(isset($nimi) || trim($nimi) != '') {
        $nimikysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Id, Nide.Tila FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Nimi ~* '(\m$nimi\M)' AND Teos.Id = Nide.Teos_id";
        $nimitulos = pg_query($nimikysely);
        
        // tulostetaan löytyneet teokset sekä tietoa niistä - nimi, tekijä, luokka, tyyppi sekä hinta
        while ($row = pg_fetch_row($nimitulos)) {
            if ($row[6] == "vapaa") {
                echo '<table>';
                // Tulostetaan kirjan tiedot
                echo '<tr><td>Nimi:   </td><td> '              . $row[0]      . '</td></tr>';
                echo '<tr><td>Tekijä: </td><td> '              . $row[1]    . '</td></tr>';
                echo '<tr><td>Luokka: </td><td> '              . $row[2]    . '</td></tr>';
                echo '<tr><td>Tyyppi: </td><td> '              . $row[3]    . '</td></tr>';
                echo '<tr><td>Hinta:  </td><td> '              . $row[4]    . '</td></tr>';
                echo '<tr><td>Nide-id:</td><td> '              . $row[5]    . '</td></tr>';
                echo '</table><br />';
                
                // lisätään ostoskoriin -nappi, lähetetään ostoskorille tieto niteen id:stä
                echo "<form action='ostoskori_lisays.php' method='post'>
                      <button name='lisaa' type='submit' value=$row[5]>Lisaa ostoskoriin</button>
                      </form>";
            }
        }
    }
    
    // jos tekijä on annettu, lähdetään tekemään hakua sen perusteella
    if(isset($tekija) || trim($tekija) != '') {
        $tekijakysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Id, Nide.Tila FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Tekija ~* '(\m$tekija\M)' AND Teos.Id = Nide.Teos_id";
        $tekijatulos = pg_query($tekijakysely);
        
        // tulostetaan löytyneet teokset sekä tietoa niistä - nimi, tekijä, luokka, tyyppi, hinta sekä niteen id
        while ($row = pg_fetch_row($tekijatulos)) {
            if ($row[6] == "vapaa") {
                echo '<table>';
                // Tulostetaan kirjan tiedot
                echo '<tr><td>Nimi:   </td><td> '              . $row[0]      . '</td></tr>';
                echo '<tr><td>Tekijä: </td><td> '              . $row[1]    . '</td></tr>';
                echo '<tr><td>Luokka: </td><td> '              . $row[2]    . '</td></tr>';
                echo '<tr><td>Tyyppi: </td><td> '              . $row[3]    . '</td></tr>';
                echo '<tr><td>Hinta:  </td><td> '              . $row[4]    . '</td></tr>';
                echo '<tr><td>Nide-id:</td><td> '              . $row[5]    . '</td></tr>';
                echo '</table><br />';
                
                // lisätään ostoskoriin -nappi, lähetetään ostoskorille tieto niteen id:stä
                echo "<form action='ostoskori_lisays.php' method='post'>
                      <button name='lisaa' type='submit' value=$row[5]>Lisaa ostoskoriin</button>
                      </form>";
            }
        }
    }
    
    // jos tyyppi on annettu, lähdetään tekemään hakua sen perusteella
    if(isset($tyyppi) || trim($tyyppi) != '') {
        $tyyppikysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Id, Nide.Tila FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Tyyppi ~* '(\m$tyyppi\M)' AND Teos.Id = Nide.Teos_id";
        $tyyppitulos = pg_query($tyyppikysely);
        
        // tulostetaan löytyneet teokset sekä tietoa niistä - nimi, tekijä, luokka, tyyppi sekä hinta
        while ($row = pg_fetch_row($tyyppitulos)) {
            if ($row[6] == "vapaa") {
                echo '<table>';
                // Tulostetaan kirjan tiedot
                echo '<tr><td>Nimi:   </td><td> '              . $row[0]      . '</td></tr>';
                echo '<tr><td>Tekijä: </td><td> '              . $row[1]    . '</td></tr>';
                echo '<tr><td>Luokka: </td><td> '              . $row[2]    . '</td></tr>';
                echo '<tr><td>Tyyppi: </td><td> '              . $row[3]    . '</td></tr>';
                echo '<tr><td>Hinta:  </td><td> '              . $row[4]    . '</td></tr>';
                echo '<tr><td>Nide-id:</td><td> '              . $row[5]    . '</td></tr>';
                echo '</table><br />';
                
                // lisätään ostoskoriin -nappi, lähetetään ostoskorille tieto niteen id:stä
                echo "<form action='ostoskori_lisays.php' method='post'>
                      <button name='lisaa' type='submit' value=$row[5]>Lisaa ostoskoriin</button>
                      </form>";
            }
        }
    }
    
    // jos luokka on annettu, lähdetään tekemään hakua sen perusteella
    if(isset($luokka) || trim($luokka) == '') {
        $luokkakysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Id, Nide.Tila FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Luokka ~* '(\m$luokka\M)' AND Teos.Id = Nide.Teos_id";
        $luokkatulos = pg_query($luokkakysely);
        
        // tulostetaan löytyneet teokset sekä tietoa niistä - nimi, tekijä, luokka, tyyppi sekä hinta
        while ($row = pg_fetch_row($luokkatulos)) {
            if ($row[6] == "vapaa") {
                echo '<table>';
                // Tulostetaan kirjan tiedot
                echo '<tr><td>Nimi:   </td><td> '              . $row[0]      . '</td></tr>';
                echo '<tr><td>Tekijä: </td><td> '              . $row[1]    . '</td></tr>';
                echo '<tr><td>Luokka: </td><td> '              . $row[2]    . '</td></tr>';
                echo '<tr><td>Tyyppi: </td><td> '              . $row[3]    . '</td></tr>';
                echo '<tr><td>Hinta:  </td><td> '              . $row[4]    . '</td></tr>';
                echo '<tr><td>Nide-id:</td><td> '              . $row[5]    . '</td></tr>';
                echo '</table><br />';
                
                // lisätään ostoskoriin -nappi, lähetetään ostoskorille tieto niteen id:stä
                echo "<form action='ostoskori_lisays.php' method='post'>
                      <button name='lisaa' type='submit' value=$row[5]>Lisaa ostoskoriin</button>
                      </form>";
            }
        }
    }
    
}

// jos asiakas painoi "Näytä ostoskori", siirrytään ostoskoriin
elseif (isset($_POST['ostoskoriin'])) {
    header('Location: ostoskori_lisays.php');
}

// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Hakutoiminto</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="haku.php" method="post">

    <h2>Kirjan hakutoiminto</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
	    <tr>
    	    <td>Teoksen nimi</td>
    	    <td><input type="text" name="nimi" value="" /></td>
	    </tr>
        <tr>
            <td>Teoksen tekijä</td>
            <td><input type="text" name="tekija" value=""/></td>
        </tr>
        <tr>
            <td>Tyyppi</td>
            <td><input type="text" name="tyyppi" value=""/></td>
        </tr>
        <tr>
            <td>Luokka</td>
            <td><input type="text" name="luokka" value=""/></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="hae" value="Hae"/></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="ostoskoriin" value="Näytä ostoskori"/></td>
        </tr>
	</table>

	<br />

</body>
</html>