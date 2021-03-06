package Lemonade::Role::Cart;

use strict;
use warnings;

=head2 add

Retrieve's cart ref from session.
Params:
    fetch_all - returns hashref containing all carts
    name - fetch specifc cart from session
    
=cut 

sub retrieve {
    my ($self, $params) = @_;

    my $carts = session->{cart};
    
    return $carts if $params->{fetch_all};

    $carts->{$params->{name} || 'default'};
}

=head2 add

Adds an item to the cart.

=cut 


sub add {
    my ($self, $params) = @_;

    return unless $params->{sku};

    return delete $params->{sku} unless $params->{quantity};

    $self->retrieve($params->{name})->{$params->{sku}}->{quantity} += 
        $params->{quantity};
}

=head2 delete

Deletes an item from the cart. 
Wrapper to add method force appending
a quantity of zero.

=cut 

sub delete {
    shift->add({ sku => shift->{sku}, quantity => 0 });
}

=head2 subtotal

Returns subtotal of all items.
Params:
    name: Name of the cart to total
    price_scheme: The pricing value to use
    
=cut 

sub cart_subtotal {
   my ($self, $params) = @_;
   
   my $cart = $self->retrieve({ name => $params->{name} });
   
   my $subtotal = 0;
   
   my $schema = $params->{price_scheme} || 'retail_price';
   
   $subtotal += $item->{$schema} * $item->{quantity}
        for my $item (@$cart);

   return sprintf("%.02f", $subtotal);
}

=head2 list_carts

Returns an array ref 
of active cart names
in session.
    
=cut 

sub list_carts{
  return [keys %{shift->retrieve({ fetch_all => 1 })}];
}

=head2 add_item_attribtues

Add/modifies current
attributes of an item.
    
=cut 

sub add_item_attribtues{
  my ($self, $params, %atttr) = @_;
  return unless $params->{sku};

  my $cart = $self->retrieve({ name => $params->{name}});

  die "Item not available in cart"
    unless exists $cart->{$params->{sku}};

  $cart->{$params->{sku}} = {
    %{$cart->{$params->{sku}}},
    %attr
  };
}

=head2 remove_item_attribtues

Removes attributes of an item.
    
=cut 

sub remove_item_attribtues{
  my ($self, $params, @keys) = @_;
  return unless $params->{sku};

  my $cart = $self->retrieve({ name => $params->{name}});

  die "Item not available in cart"
    unless exists $cart->{$params->{sku}};

  return { delete %{$cart}{@keys} };
}

=head1 AUTHOR

Nick Piscitelli (oddesey) <mail@nickpiscitelli.com>

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2011 Lemonade Stand <lemonade@lemonade-stand.com>.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;