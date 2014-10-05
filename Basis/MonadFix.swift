//
//  File.swift
//  Basis
//
//  Created by Robert Widmann on 9/13/14.
//  Copyright (c) 2014 TypeLift. All rights reserved.
//  Released under the MIT license.
//

/// Monads that admit left-tightening recursion.
public protocol MonadFix : Monad {
	/// Calculates the fixed point of a monadic computation.
	class func mfix(A -> FA) -> FA
}

// Uncomment to crash Swiftc
//extension Maybe : MonadFix {
//	public class func mfix(f : A -> Maybe<A>) -> Maybe<A> {
//		return f(fromSome(mfix(f)))
//	}
//}
