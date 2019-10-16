# Packer Build Actions

## Inputs

### `template`

The packer template to run

### `working_dir`

What directory to execute it in.

### `additional_info_file`

It is best practice to add build information to the ami, and to output the artifact meta-data so it uses a [template](./build-info.tpl.json) to merge that json in.  You can supply a new template or point at no file to have no changes made.



## Outputs

### `image_id`

The ami that was created (only works if you have a manifest post-processor, which the `additional_info_file` provides)
