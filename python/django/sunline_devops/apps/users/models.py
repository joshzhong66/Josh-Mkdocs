from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _

class User(AbstractUser):
    """自定义用户模型"""
    ROLE_CHOICES = (
        ('admin', '管理员'),
        ('ops', '运维人员'),
        ('dev', '开发人员'),
        ('user', '普通用户'),
    )

    mobile = models.CharField(_('手机号'), max_length=11, unique=True, null=True, blank=True)
    role = models.CharField(_('角色'), max_length=10, choices=ROLE_CHOICES, default='user')
    department = models.CharField(_('部门'), max_length=32, null=True, blank=True)
    position = models.CharField(_('职位'), max_length=32, null=True, blank=True)
    avatar = models.ImageField(_('头像'), upload_to='avatars/', null=True, blank=True)
    is_active = models.BooleanField(_('激活状态'), default=True)
    created_time = models.DateTimeField(_('创建时间'), auto_now_add=True)
    updated_time = models.DateTimeField(_('更新时间'), auto_now=True)

    class Meta:
        verbose_name = _('用户')
        verbose_name_plural = verbose_name
        ordering = ['-date_joined']

    def __str__(self):
        return self.username