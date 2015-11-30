#!/bin/bash
make install
python manage.py collectstatic --noinput
echo "from django.contrib.auth.models import User; \
      User.objects.create_superuser('admin', 'admin@example.com', 'password12')" \
      | python manage.py shell
make test
