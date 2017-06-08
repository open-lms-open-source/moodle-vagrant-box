package.box:
	vagrant destroy
	vagrant up
	vagrant ssh -c "sudo /vagrant/scripts/cleanup.sh"
	vagrant ssh -c "sudo /vagrant/scripts/minimize.sh"
	vagrant package

	# Print the size of the box.
	du -sh package.box

.PHONY: clean
clean:
	rm -f package.box
