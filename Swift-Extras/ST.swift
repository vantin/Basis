//
//  ST.swift
//  Swift_Extras
//
//  Created by Robert Widmann on 9/10/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

// The strict state-transformer monad.  ST<S, A> represents
// a computation returning a value of type A using some internal
// context of type S.
public final class ST<S, A> : K2<S, A> {
	typealias B = Any
	
	internal var apply:(s: World<RealWorld>) -> (World<RealWorld>, A)
	
	internal init(apply:(s: World<RealWorld>) -> (World<RealWorld>, A)) {
		self.apply = apply
	}
	
	// Returns the value after completing all transformations.
	public func runST() -> A {
		let (_, x) = self.apply(s: realWorld)
		return x
	}
	
	public func ap<B>(stfn: ST<S, A -> B>) -> ST<S, B> {
		return ST<S, B>(apply: { (let s) in
			let (nw, f) = stfn.apply(s: s)
			return (nw, f(self.runST()))
		})
	}
}

extension ST : Functor {
	public class func fmap<B>(f: A -> B) -> ST<S, A> -> ST<S, B> {
		return { (let st) in
			return ST<S, B>(apply: { (let s) in
				let (nw, x) = st.apply(s: s)
				return (nw, f(x))
			})
		}
	}
}

public func <%><S, A, B>(f: A -> B, st: ST<S, A>) -> ST<S, B> {
	return ST.fmap(f)(st)
}

public func <^<S, A, B>(x : A, l : ST<S, B>) -> ST<S, A> {
	return ST.fmap(const(x))(l)
}

extension ST : Applicative {
	typealias FAB = ST<S, A -> B>

	public class func pure<S, A>(a: A) -> ST<S, A> {
		return ST<S, A>(apply: { (let s) in
			return (s, a)
		})
	}
}

public func <*><S, A, B>(stfn: ST<S, A -> B>, st: ST<S, A>) -> ST<S, B> {
	return st.ap(stfn)
}

public func *><S, A, B>(a : ST<S, A>, b : ST<S, B>) -> ST<S, B> {
	return const(id) <%> a <*> b
}

public func <*<S, A, B>(a : ST<S, A>, b : ST<S, B>) -> ST<S, A> {
	return const <%> a <*> b
}

extension ST : Monad {
	typealias MB = ST<S, B>
	
	public func bind<B>(f: A -> ST<S, B>) -> ST<S, B> {
		return f(runST())
	}
}


public func >>=<S, A, B>(x : ST<S, A>, f : A -> ST<S, B>) -> ST<S, B> {
	return x.bind(f)
}

public func >><S, A, B>(x : ST<S, A>, y : ST<S, B>) -> ST<S, B> {
	return x.bind({ (_) in
		return y
	})
}

// Shifts an ST computation into the IO monad.  Only ST's indexed
// by the real world qualify to be converted.
internal func stToIO<A>(m: ST<RealWorld, A>) -> IO<A> {
	return IO<A>.pure(m.runST())
}