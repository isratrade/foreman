require 'test_helper'

class RoleTest < ActiveSupport::TestCase

    # should have_many(:user_roles)
    # should have_many(:users).through(:user_roles)

    # should validate_presence_of(:name)
    # should validate_uniqueness_of(:name)
    # should ensure_length_of(:name).is_at_most(30)
    # should allow_value("a role name").for(:name)
    # should_not allow_value(";a role name").for(:name)
    # should_not allow_value(" a role name").for(:name)
    # should_not allow_value("a role name ").for(:name)

  def test_add_permission
    role = Role.find(1)
    size = role.permissions.size
    role.add_permission!("apermission", "anotherpermission")
    role.reload
    assert role.permissions.include?(:anotherpermission)
    assert_equal size + 2, role.permissions.size
  end

  def test_remove_permission
    role = Role.find(1)
    size = role.permissions.size
    perm = role.permissions[0..1]
    role.remove_permission!(*perm)
    role.reload
    assert ! role.permissions.include?(perm[0])
    assert_equal size - 2, role.permissions.size
  end

  context "System roles" do
    should "return the anonymous role" do
      role = Role.anonymous
      assert role.builtin?
      assert_equal Role::BUILTIN_ANONYMOUS, role.builtin
    end

    context "with a missing anonymous role" do
      setup do
        Role.delete_all("builtin = #{Role::BUILTIN_ANONYMOUS}")
      end

      should "create a new anonymous role" do
        assert_difference('Role.count') do
          Role.anonymous
        end
      end

      should "return the anonymous role" do
        role = Role.anonymous
        assert role.builtin?
        assert_equal Role::BUILTIN_ANONYMOUS, role.builtin
      end
    end
  end

  context "Default_user" do
    should "return the default_user role" do
      role = Role.default_user
      assert role.builtin?
      assert_equal Role::BUILTIN_DEFAULT_USER, role.builtin
    end

    context "with a missing default_user role" do
      setup do
        Role.delete_all("builtin = #{Role::BUILTIN_DEFAULT_USER}")
      end

      should "create a new default_user role" do
        assert_difference('Role.count') do
          Role.default_user
        end
      end

      should "return the default_user role" do
        role = Role.default_user
        assert role.builtin?
        assert_equal Role::BUILTIN_DEFAULT_USER, role.builtin
      end
    end
  end
end
