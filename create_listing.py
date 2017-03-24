#!/usr/bin/env python
import json
import sys

def createListing(datafile, listingfile):

	print("Opening %s" % datafile)
	with open(datafile,"r") as infile:
		sims = json.load(infile)['simulations']

	for client, data in sims.items():
		if "ethereum/consensus" not in data.keys():
			return

		s_len = len(data["ethereum/consensus"]["subresults"])
		data["ethereum/consensus"]["subresults"] = s_len

	file_entry = { "filename" : datafile,
					"simulations" : sims}

	try:
		print("Opening %s" % listingfile)
		with open(listingfile,"r") as infile:
			listing = json.load(infile)
	except Exception, e:
		listing = {"files" : []}


	listing["files"].append(file_entry)
	with open(listingfile,"w+") as outfile:
		print("Writing %s" % listingfile)

		json.dump(listing, outfile)

if __name__ == '__main__':

	if len(sys.argv) != 3:
		print("Usage : ")
		print("create_listing <datafile> <listingfile>")
		sys.exit(1)

	createListing(sys.argv[1], sys.argv[2])
	sys.exit(0)