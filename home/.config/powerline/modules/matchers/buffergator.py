import os


def buffergator(matcher_info):
	name = matcher_info['buffer'].name
	return name and os.path.basename(name) == '[[buffergator-buffers]]'
