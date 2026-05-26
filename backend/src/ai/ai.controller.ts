import {
  Controller,
  Post,
  Get,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AiService } from './ai.service';
import { SendMessageDto, GetRecommendationsDto, AiInsightRequestDto, AiSearchDto } from './dto/ai.dto';

@ApiTags('ai')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  @ApiOperation({ summary: 'Send a message to AI assistant' })
  sendMessage(@Request() req: { user: { id: string } }, @Body() dto: SendMessageDto) {
    return this.aiService.sendMessage(req.user.id, dto);
  }

  @Get('conversations')
  @ApiOperation({ summary: 'List user conversations' })
  getConversations(@Request() req: { user: { id: string } }) {
    return this.aiService.getConversations(req.user.id);
  }

  @Get('conversations/:id')
  @ApiOperation({ summary: 'Get conversation with messages' })
  getConversation(@Request() req: { user: { id: string } }, @Param('id') id: string) {
    return this.aiService.getConversation(req.user.id, id);
  }

  @Delete('conversations/:id')
  @ApiOperation({ summary: 'Delete a conversation' })
  deleteConversation(@Request() req: { user: { id: string } }, @Param('id') id: string) {
    return this.aiService.deleteConversation(req.user.id, id);
  }

  @Post('recommendations')
  @ApiOperation({ summary: 'Get AI-powered recommendations' })
  getRecommendations(@Request() req: { user: { id: string } }, @Body() dto: GetRecommendationsDto) {
    return this.aiService.getRecommendations(req.user.id, dto);
  }

  @Post('insights')
  @ApiOperation({ summary: 'Get AI insights from data' })
  getInsights(@Request() req: { user: { id: string } }, @Body() dto: AiInsightRequestDto) {
    return this.aiService.getInsights(req.user.id, dto);
  }

  @Post('search')
  @ApiOperation({ summary: 'AI-powered semantic search' })
  search(@Request() req: { user: { id: string } }, @Body() dto: AiSearchDto) {
    return this.aiService.search(req.user.id, dto);
  }
}
