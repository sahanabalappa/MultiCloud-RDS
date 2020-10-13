resource "aws_db_instance" "wp_db" {
        allocated_storage    = 20
        storage_type         = "gp2"
        engine               = "mysql"
        engine_version       = 5.7
        instance_class       = "db.t2.micro"
        name                 = "db"
        username             = "admin"
        password             = "password"
        parameter_group_name = "default.mysql5.7"
        publicly_accessible  = true
        skip_final_snapshot  = true
	}

