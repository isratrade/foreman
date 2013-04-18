# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'

Audit = Audited.audit_class
Audit.send(:include, AuditExtentions)