// Objective-C API for talking to github.com/EpiK-Protocol/epik-wallet-golib/hd Go package.
//   gobind -lang=objc -prefix="EPIK_" github.com/EpiK-Protocol/epik-wallet-golib/hd
//
// File is generated by gobind. Do not edit.

#ifndef __EPIK_Hd_H__
#define __EPIK_Hd_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class EPIK_HdAmounts;
@class EPIK_HdUniswapInfo;
@class EPIK_HdWallet;

/**
 * Amounts ...
 */
@interface EPIK_HdAmounts : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull amountIn;
@property (nonatomic) NSString* _Nonnull amountOut;
@end

/**
 * UniswapInfo ...
 */
@interface EPIK_HdUniswapInfo : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull epk;
@property (nonatomic) NSString* _Nonnull usdt;
@property (nonatomic) NSString* _Nonnull uni;
@property (nonatomic) NSString* _Nonnull share;
@property (nonatomic) int64_t lastBlockTime;
@end

/**
 * Wallet ...
 */
@interface EPIK_HdWallet : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
/**
 * AccelerateTx 加速交易
 */
- (NSString* _Nonnull)accelerateTx:(NSString* _Nullable)srcTxHash gasRate:(double)gasRate error:(NSError* _Nullable* _Nullable)error;
/**
 * Accounts ...
 */
- (NSString* _Nonnull)accounts;
/**
 * Balance ...
 */
- (NSString* _Nonnull)balance:(NSString* _Nullable)address error:(NSError* _Nullable* _Nullable)error;
/**
 * CancelTx 取消交易
 */
- (NSString* _Nonnull)cancelTx:(NSString* _Nullable)srcTxHash error:(NSError* _Nullable* _Nullable)error;
/**
 * Contains ...
 */
- (BOOL)contains:(NSString* _Nullable)address;
/**
 * Derive ...
 */
- (NSString* _Nonnull)derive:(NSString* _Nullable)path pin:(BOOL)pin error:(NSError* _Nullable* _Nullable)error;
- (NSString* _Nonnull)export:(NSString* _Nullable)address error:(NSError* _Nullable* _Nullable)error;
/**
 * Receipt  ...
 */
- (NSString* _Nonnull)receipt:(NSString* _Nullable)txHash error:(NSError* _Nullable* _Nullable)error;
/**
 * SetRPC ...
 */
- (BOOL)setRPC:(NSString* _Nullable)url error:(NSError* _Nullable* _Nullable)error;
/**
 * SignHash ...
 */
- (NSData* _Nullable)signHash:(NSString* _Nullable)address hash:(NSData* _Nullable)hash error:(NSError* _Nullable* _Nullable)error;
/**
 * SignText ...
 */
- (NSData* _Nullable)signText:(NSString* _Nullable)address text:(NSString* _Nullable)text error:(NSError* _Nullable* _Nullable)error;
/**
 * SuggestGas ...
 */
- (NSString* _Nonnull)suggestGas:(NSError* _Nullable* _Nullable)error;
/**
 * SuggestGasPrice ...
 */
- (NSString* _Nonnull)suggestGasPrice:(NSError* _Nullable* _Nullable)error;
/**
 * TokenBalance ...
 */
- (NSString* _Nonnull)tokenBalance:(NSString* _Nullable)address currency:(NSString* _Nullable)currency error:(NSError* _Nullable* _Nullable)error;
/**
 * Transactions ...
 */
- (NSString* _Nonnull)transactions:(NSString* _Nullable)address currency:(NSString* _Nullable)currency page:(int64_t)page offset:(int64_t)offset asc:(BOOL)asc error:(NSError* _Nullable* _Nullable)error;
/**
 * Transfer ...
 */
- (NSString* _Nonnull)transfer:(NSString* _Nullable)from to:(NSString* _Nullable)to amount:(NSString* _Nullable)amount error:(NSError* _Nullable* _Nullable)error;
/**
 * TransferToken ...
 */
- (NSString* _Nonnull)transferToken:(NSString* _Nullable)from to:(NSString* _Nullable)to currency:(NSString* _Nullable)currency amount:(NSString* _Nullable)amount error:(NSError* _Nullable* _Nullable)error;
/**
 * UniswapAddLiquidity ...
 */
- (NSString* _Nonnull)uniswapAddLiquidity:(NSString* _Nullable)address tokenA:(NSString* _Nullable)tokenA tokenB:(NSString* _Nullable)tokenB amountADesired:(NSString* _Nullable)amountADesired amountBDesired:(NSString* _Nullable)amountBDesired amountAMin:(NSString* _Nullable)amountAMin amountBMin:(NSString* _Nullable)amountBMin deadline:(NSString* _Nullable)deadline error:(NSError* _Nullable* _Nullable)error;
/**
 * UniswapExactTokenForTokens ...
 */
- (NSString* _Nonnull)uniswapExactTokenForTokens:(NSString* _Nullable)address tokenA:(NSString* _Nullable)tokenA tokenB:(NSString* _Nullable)tokenB amountIn:(NSString* _Nullable)amountIn amountOutMin:(NSString* _Nullable)amountOutMin deadline:(NSString* _Nullable)deadline error:(NSError* _Nullable* _Nullable)error;
/**
 * UniswapGetAmountsOut ...
 */
- (EPIK_HdAmounts* _Nullable)uniswapGetAmountsOut:(NSString* _Nullable)tokenA tokenB:(NSString* _Nullable)tokenB amountIn:(NSString* _Nullable)amountIn error:(NSError* _Nullable* _Nullable)error;
/**
 * UniswapInfo ...
 */
- (EPIK_HdUniswapInfo* _Nullable)uniswapInfo:(NSString* _Nullable)address error:(NSError* _Nullable* _Nullable)error;
/**
 * UniswapRemoveLiquidity ...
 */
- (NSString* _Nonnull)uniswapRemoveLiquidity:(NSString* _Nullable)address tokenA:(NSString* _Nullable)tokenA tokenB:(NSString* _Nullable)tokenB liquidity:(NSString* _Nullable)liquidity amountAMin:(NSString* _Nullable)amountAMin amountBMin:(NSString* _Nullable)amountBMin deadline:(NSString* _Nullable)deadline error:(NSError* _Nullable* _Nullable)error;
@end

// skipped const EPK with unsupported type: github.com/EpiK-Protocol/epik-wallet-golib/hd.currencyType

// skipped const UNI with unsupported type: github.com/EpiK-Protocol/epik-wallet-golib/hd.currencyType

// skipped const USDT with unsupported type: github.com/EpiK-Protocol/epik-wallet-golib/hd.currencyType


/**
 * NewFromMnemonic ...
 */
FOUNDATION_EXPORT EPIK_HdWallet* _Nullable EPIK_HdNewFromMnemonic(NSString* _Nullable mnemonic, NSError* _Nullable* _Nullable error);

/**
 * NewFromSeed ...
 */
FOUNDATION_EXPORT EPIK_HdWallet* _Nullable EPIK_HdNewFromSeed(NSData* _Nullable seed, NSError* _Nullable* _Nullable error);

/**
 * NewMnemonic ...
 */
FOUNDATION_EXPORT NSString* _Nonnull EPIK_HdNewMnemonic(long bits, NSError* _Nullable* _Nullable error);

/**
 * NewSeed ...
 */
FOUNDATION_EXPORT NSData* _Nullable EPIK_HdNewSeed(NSError* _Nullable* _Nullable error);

/**
 * SeedFromMnemonic ...
 */
FOUNDATION_EXPORT NSData* _Nullable EPIK_HdSeedFromMnemonic(NSString* _Nullable mnemonic, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT void EPIK_HdSetDebug(BOOL debug);

#endif