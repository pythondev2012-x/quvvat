from django.apps import AppConfig


class MainConfig(AppConfig):
    name = 'main'
    verbose_name = "Do‘kon"

    def ready(self):
        from . import signals  # noqa: F401 - signallarni ro'yxatdan o'tkazadi
