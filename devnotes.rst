

snapshot that is used by an (exported) ami image is protected by delete.
delete will result in error that they are used by AMI ID ... and will fail.

volume images are not used by AMI image, only by instance.  if instance is destroyed, the volume can be deleted.
