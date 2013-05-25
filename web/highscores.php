<?php
$db = new mysqli('localhost', 'user', 'password', 'database');
/*
CREATE TABLE `scores` (
	`id`	int(11) NOT NULL AUTO_INCREMENT,
	`date`	datetime NOT NULL,
	`name`	varchar(12) COLLATE utf8_unicode_ci NOT NULL,
	`score`	int(11) NOT NULL,
	PRIMARY KEY (`id`)
)
 */

if($_SERVER['REQUEST_METHOD'] == "POST"){
	if($qry = $db->prepare("INSERT INTO `scores` (date, name, score) VALUES (NOW(), ?, ?)")){
		if(isset($_POST['name']) && isset($_POST['score'])){
			$qry->bind_param("ss", $_POST['name'], $_POST['score']);
			$qry->execute();
			$qry->close();
		}
	}
}

if($_SERVER['REQUEST_METHOD'] == "GET"){
?>
<!doctype html>
<html>
	<head>
		<title>TippTippReloaded Highscores</title>
		<meta charset="utf-8">
	</head>
	<body>
		<h1><a href="https://github.com/Ps0ke/TippTippReloaded">TippTippReloaded</a> Highscores</h1>
		<table>
			<thead>
				<tr>
					<th>Date</th>
					<th>Score</th>
					<th>Name</th>
				</tr>
			</thead>
			<tbody>
<?php
	$highscores = $db->query("SELECT s.name, MAX(score) as score, (SELECT s2.date as date FROM scores s2 WHERE s.name = s2.name ORDER by s2.score DESC LIMIT 1) as date FROM scores s GROUP BY s.name ORDER by score DESC LIMIT 10");
	while($score = $highscores->fetch_assoc()){
		echo "\t\t\t\t<tr>\n\t\t\t\t\t<td>".htmlspecialchars($score['date'])."</td>\n";
		echo "\t\t\t\t\t<td>".htmlspecialchars($score['score'])."</td>\n";
		echo "\t\t\t\t\t<td>".htmlspecialchars($score['name'])."</td>\n\t\t\t\t</tr>\n";
	}
?>
			</tbody>
		</table>
	</body>
</html>
<?php
}
?>

