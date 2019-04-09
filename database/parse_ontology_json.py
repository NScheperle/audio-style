import json
import mysql.connector

cnx = mysql.connector.connect(user='nes31', database= 'AudioSet')
cur = cnx.cursor()

filename = "./database/ontology.json"

f = open(filename)

data = json.load(f)

insert_query = ("INSERT INTO Ontology (ID, Name, Description, Citation_uri, Child_IDs)"
          " VALUES (%s, %s, %s, %s, %s);")

for i,doc in enumerate(data):
	if i % 100 == 0:
		print("Iteration: {}".format(i))
	check_query = ("SELECT EXISTS(SELECT * from Ontology WHERE ID = %s);")
	#cur.execute(check_query, (doc['id'],))
	#check_exists = cur.fetchone()[0] == 1
	check_exists = False

	if check_exists:
		print("{} already exists in DB".format(fn))
		continue
	#print((doc['id'], doc['name'], doc['description'], doc['citation_uri'],  ','.join(doc['child_ids'])))
	#print(len(doc['description']))
	#break
	cur.execute(insert_query,(doc['id'], doc['name'], doc['description'], doc['citation_uri'], ','.join(doc['child_ids'])))

cnx.commit()
cnx.close()