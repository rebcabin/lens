{-# LANGUAGE CPP #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Complex.Lens
-- Copyright   :  (C) 2012 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  Rank2Types
--
----------------------------------------------------------------------------
module Data.Complex.Lens
  ( real, imaginary, polarize
  , traverseComplex
  ) where

import Control.Applicative
import Control.Lens
import Data.Complex

-- | Access the 'realPart' of a 'Complex' number
--
-- >>> real (1.0 :+ 0.0)
-- 1.0
--
-- @'real' :: 'Functor' f => (a -> f a) -> 'Complex' a -> f ('Complex' a)@
#if MIN_VERSION_base(4,4,0)
real :: Simple Lens (Complex a) a
#else
real :: RealFloat a => Simple Lens (Complex a) a
#endif
real f (a :+ b) = (:+ b) <$> f a

-- | Access the 'imaginaryPart' of a 'Complex' number
--
-- >>> imaginary (0.0 :+ 1.0)
-- 1.0
--
-- @'imaginary' :: 'Functor' f => (a -> f a) -> 'Complex' a -> f ('Complex' a)@
#if MIN_VERSION_base(4,4,0)
imaginary :: Simple Lens (Complex a) a
#else
imaginary :: RealFloat a => Simple Lens (Complex a) a
#endif
imaginary f (a :+ b) = (a :+) <$> f b

-- | This isn't /quite/ a legal lens. Notably the 
--
-- @'view' l ('set' l b a) = b@
--
-- law is violated when you set a 'polar' value with 0 'magnitude' and non-zero 'phase'
-- as the 'phase' information is lost. So don't do that!
--
-- Otherwise, this is a perfectly cromulent 'Lens'.
--
-- >>> (0.0 :+ 1.0)^.polarize
-- (1.0,1.5707963267948966)
--
-- >>> (1.0,pi)^.from polarize
-- (-1.0) :+ 1.2246467991473532e-16
polarize :: (RealFloat a, RealFloat b) => Iso (Complex a) (Complex b) (a,a) (b,b)
polarize = isos polar (uncurry mkPolar)
                polar (uncurry mkPolar)

-- | Traverse both the real and imaginary parts of a 'Complex' number.
--
-- > traverseComplex :: Applicative f => (a -> f b) -> Complex a -> f (Complex b)
#if MIN_VERSION_base(4,4,0)
traverseComplex :: Traversal (Complex a) (Complex b) a b
#else
traverseComplex :: (RealFloat a, RealFloat b) => Traversal (Complex a) (Complex b) a b
#endif
traverseComplex f (a :+ b) = (:+) <$> f a <*> f b
